import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../constants.dart';
import 'chat.dart';

void showNewTeacherMessageBottomSheet(BuildContext context, int? messageSendPermissionsApp) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false, // Prevents dismissing by tapping outside
    enableDrag: false, // Disables drag-to-dismiss
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 1.0, // Full height by default
      minChildSize: 1.0, // Minimum size is full height
      maxChildSize: 1.0, // Maximum size is full height
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: NewTeacherMessageScreen(
          messageSendPermissionsApp: messageSendPermissionsApp,
          scrollController: controller,
        ),
      ),
    ),
  );
}

class NewTeacherMessageScreen extends StatefulWidget {
  final int? messageSendPermissionsApp;
  final ScrollController scrollController;
  const NewTeacherMessageScreen({
    super.key,
    required this.messageSendPermissionsApp,
    required this.scrollController,
  });

  @override
  State<NewTeacherMessageScreen> createState() => _NewTeacherMessageScreenState();
}

class _NewTeacherMessageScreenState extends State<NewTeacherMessageScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List messsage = [];
  List students = [];
  List filteredMessages = [];
  List filteredMessages2 = [];
  Set<int> selectedTeachers = {};
  Set<int> selectedStudents = {};
  late TabController _tabController;
  bool selectAllTeachers = false;
  bool selectAllStudents = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchAssignmentsData();
    _searchController.addListener(_filterMessages);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {
      _searchController.clear();
      _filterMessages();
    });
  }

  Future<void> fetchAssignmentsData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('teachertoken');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiRoutes.getAllTeacherMessages),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          messsage = jsonResponse['users'] ?? [];
          students = jsonResponse['students'] ?? [];
          filteredMessages =  messsage;
          filteredMessages2 =  students;
          // filteredMessages = _tabController.index == 0 ? messsage : students;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data. ')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterMessages() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (_tabController.index == 0) {
        filteredMessages = messsage.where((assignment) {
          final name = assignment['first_name']?.toString().toLowerCase() ?? '';
          final designation = assignment['designation']?['title']?.toString().toLowerCase() ?? '';
          return name.contains(query) || designation.contains(query);
        }).toList();
      } else {
        filteredMessages2 = students.where((assignment) {
          final name = assignment['student_name']?.toString().toLowerCase() ?? '';
          final className = assignment['class_name']?.toString().toLowerCase() ?? '';
          return name.contains(query) || className.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _sendMessage(String msg, int senderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in.')),
      );
      return;
    }

    try {
      final uri = Uri.parse(ApiRoutes.sendMessage);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['receivers[]'] = 'user_$senderId';
      request.fields['body'] = msg;

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _showMessagePopup(BuildContext context, String name, String subtitle, int id) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController messageController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Message\n($name)',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  _sendMessage(message, id);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a message'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Permission Denied',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Sorry, you don\'t have permission to send messages at this time. Please contact support for assistance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: const Text(
                      'Close',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_tabController.index == 0) {
        if (selectedTeachers.contains(id)) {
          selectedTeachers.remove(id);
        } else {
          selectedTeachers.add(id);
        }
        selectAllTeachers = selectedTeachers.length == messsage.length;
      } else {
        if (selectedStudents.contains(id)) {
          selectedStudents.remove(id);
        } else {
          selectedStudents.add(id);
        }
        selectAllStudents = selectedStudents.length == students.length;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_tabController.index == 0) {
        if (selectAllTeachers) {
          selectedTeachers.clear();
        } else {
          selectedTeachers.addAll(messsage.map((user) => user['id'] as int));
        }
        selectAllTeachers = !selectAllTeachers;
      } else {
        if (selectAllStudents) {
          selectedStudents.clear();
        } else {
          selectedStudents.addAll(students.map((student) => student['id'] as int));
        }
        selectAllStudents = !selectAllStudents;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 18.sp),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'New Messages',
                  style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textwhite,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textwhite),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),


        SizedBox(
          height: 45.sp,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 15.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey, size: 15.sp),
                  onPressed: () {
                    _searchController.clear();
                    _filterMessages();
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
        Container(
          color: AppColors.secondary,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.textwhite,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: AppColors.primary,
            tabs:  [
              Tab(text: 'Teachers ${'(${filteredMessages.length.toString()})'}'),
              Tab(text: 'Students ${'(${filteredMessages2.length.toString()})'}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6, // Smaller checkbox as per your request
                child: Checkbox(
                  value: _tabController.index == 0 ? selectAllTeachers : selectAllStudents,
                  onChanged: (value) => _toggleSelectAll(),
                  activeColor: AppColors.primary,
                ),
              ),
              Text(
                'Select All',
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textwhite,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Teachers Tab
              isLoading
                  ? const WhiteCircularProgressWidget()
                  : filteredMessages.isEmpty
                  ? const Center(
                child: DataNotFoundWidget(
                  title: 'No Teachers Found.',
                ),
              )
                  : ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final assignment = filteredMessages[index];
                  final isSelected = selectedTeachers.contains(assignment['id']);
                  return GestureDetector(
                    onTap: () {
                      if (widget.messageSendPermissionsApp == 0) {
                        _showPermissionDeniedPopup(context);
                      } else {
                        _showMessagePopup(
                          context,
                          assignment['first_name'] ?? 'Unknown',
                          assignment['designation']?['title']?.toString() ?? 'No Designation',
                          assignment['id'],
                        );
                      }
                    },
                    onLongPress: () => _toggleSelection(assignment['id']),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 5.sp),
                      elevation: 6,
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.sp),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(0.sp),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.6, // Smaller checkbox
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (value) => _toggleSelection(assignment['id']),
                                activeColor: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${assignment['first_name']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '(${assignment['designation']?['title']?.toString().toUpperCase() ?? 'NO DESIGNATION'})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Students Tab
              isLoading
                  ? const WhiteCircularProgressWidget()
                  : filteredMessages2.isEmpty
                  ? const Center(
                child: DataNotFoundWidget(
                  title: 'No Students Found.',
                ),
              )
                  : ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredMessages2.length,
                itemBuilder: (context, index) {
                  final assignment = filteredMessages2[index];
                  final isSelected = selectedStudents.contains(assignment['id']);
                  return GestureDetector(
                    onTap: () {
                      if (widget.messageSendPermissionsApp == 0) {
                        _showPermissionDeniedPopup(context);
                      } else {
                        _showMessagePopup(
                          context,
                          assignment['student_name'] ?? 'Unknown',
                          '${assignment['class_name']?.toString() ?? 'No Class'} (${assignment['section']?.toString() ?? 'No Section'})',
                          assignment['id'],
                        );
                      }
                    },
                    onLongPress: () => _toggleSelection(assignment['id']),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 5.sp),
                      elevation: 6,
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.sp),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(0.sp),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.7, // Smaller checkbox
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (value) => _toggleSelection(assignment['id']),
                                activeColor: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${assignment['student_name']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${assignment['class_name']?.toString().toUpperCase() ?? 'NO CLASS'} (${assignment['section']?.toString().toUpperCase() ?? 'NO SECTION'})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}