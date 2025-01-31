// import 'package:flutter/material.dart';
//
// class LibraryScreen extends StatelessWidget {
//   const LibraryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Library Screen'),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryScreen extends StatelessWidget {
  // Sample list of books
  final List<Map<String, dynamic>> books = [
    {
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "availability": "Available",
      "imageUrl": "https://img.freepik.com/free-psd/books-stack-icon-isolated-3d-render-illustration_47987-15482.jpg?t=st=1738053254~exp=1738056854~hmac=37b7fadb6bf59829072e88460ac1f6b4fbe9078762eb3ebacad3996c7822f14f&w=996"
    },
    {
      "title": "1984",
      "author": "George Orwell",
      "availability": "Checked Out",
      "imageUrl": "https://img.freepik.com/free-psd/books-stack-icon-isolated-3d-render-illustration_47987-15482.jpg?t=st=1738053254~exp=1738056854~hmac=37b7fadb6bf59829072e88460ac1f6b4fbe9078762eb3ebacad3996c7822f14f&w=996"
    },
    {
      "title": "To Kill a Mockingbird",
      "author": "Harper Lee",
      "availability": "Available",
      "imageUrl": "https://img.freepik.com/free-psd/books-stack-icon-isolated-3d-render-illustration_47987-15482.jpg?t=st=1738053254~exp=1738056854~hmac=37b7fadb6bf59829072e88460ac1f6b4fbe9078762eb3ebacad3996c7822f14f&w=996"
    },
    {
      "title": "Pride and Prejudice",
      "author": "Jane Austen",
      "availability": "Available",
      "imageUrl": "https://img.freepik.com/free-psd/books-stack-icon-isolated-3d-render-illustration_47987-15482.jpg?t=st=1738053254~exp=1738056854~hmac=37b7fadb6bf59829072e88460ac1f6b4fbe9078762eb3ebacad3996c7822f14f&w=996"
    },
    {
      "title": "The Catcher in the Rye",
      "author": "J.D. Salinger",
      "availability": "Checked Out",
      "imageUrl": "https://img.freepik.com/free-psd/books-stack-icon-isolated-3d-render-illustration_47987-15482.jpg?t=st=1738053254~exp=1738056854~hmac=37b7fadb6bf59829072e88460ac1f6b4fbe9078762eb3ebacad3996c7822f14f&w=996"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Library",
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Text(
              "Available Books",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Book List
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        book['imageUrl'],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        book['title'],
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Author: ${book['author']}\nStatus: ${book['availability']}",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        book['availability'] == "Available"
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: book['availability'] == "Available"
                            ? Colors.green
                            : Colors.red,
                      ),
                      onTap: () {
                        // Navigate to a book details screen (optional)
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// class LibraryScreen extends StatefulWidget {
//   @override
//   _LibraryScreenState createState() => _LibraryScreenState();
// }
//
// class _LibraryScreenState extends State<LibraryScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
//
//   List<Map<String, dynamic>> books = [
//     {
//       "title": "Flutter for Beginners",
//       "author": "John Smith",
//       "image": "https://source.unsplash.com/200x300/?book,technology",
//       "category": "Technology",
//       "isFavorite": false
//     },
//     {
//       "title": "The Science of AI",
//       "author": "Jane Doe",
//       "image": "https://source.unsplash.com/200x300/?book,ai",
//       "category": "Science",
//       "isFavorite": false
//     },
//     {
//       "title": "World History",
//       "author": "Richard Brown",
//       "image": "https://source.unsplash.com/200x300/?book,history",
//       "category": "History",
//       "isFavorite": false
//     },
//     {
//       "title": "Psychology 101",
//       "author": "Emily Davis",
//       "image": "https://source.unsplash.com/200x300/?book,psychology",
//       "category": "Psychology",
//       "isFavorite": false
//     }
//   ];
//
//   List<String> categories = ["All", "Technology", "Science", "History", "Psychology"];
//   String selectedCategory = "All";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           "Library",
//           style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           _buildCategoryTabs(),
//           Expanded(child: _buildBookList()),
//         ],
//       ),
//     );
//   }
//
//   // 📌 Search Bar
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (value) {
//           setState(() {
//             _searchQuery = value;
//           });
//         },
//         decoration: InputDecoration(
//           prefixIcon: Icon(Icons.search, color: Colors.grey),
//           hintText: "Search books...",
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//         ),
//       ),
//     );
//   }
//
//   // 📌 Category Tabs
//   Widget _buildCategoryTabs() {
//     return Container(
//       height: 50,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         children: categories.map((category) {
//           bool isSelected = category == selectedCategory;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = category;
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               margin: EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.blue : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//               ),
//               child: Center(
//                 child: Text(
//                   category,
//                   style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // 📌 Book List
//   Widget _buildBookList() {
//     List<Map<String, dynamic>> filteredBooks = books.where((book) {
//       return (selectedCategory == "All" || book["category"] == selectedCategory) &&
//           (book["title"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
//               book["author"].toLowerCase().contains(_searchQuery.toLowerCase()));
//     }).toList();
//
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: filteredBooks.length,
//       itemBuilder: (context, index) {
//         return _buildBookCard(filteredBooks[index]);
//       },
//     );
//   }
//
//   // 📌 Book Card
//   Widget _buildBookCard(Map<String, dynamic> book) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: CachedNetworkImage(
//             imageUrl: book["image"],
//             width: 60,
//             height: 90,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => Container(color: Colors.grey[300]),
//             errorWidget: (context, url, error) => Icon(Icons.image, color: Colors.grey),
//           ),
//         ),
//         title: Text(
//           book["title"],
//           style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text(
//           book["author"],
//           style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
//         ),
//         trailing: IconButton(
//           icon: Icon(book["isFavorite"] ? Icons.favorite : Icons.favorite_border, color: book["isFavorite"] ? Colors.red : Colors.grey),
//           onPressed: () {
//             setState(() {
//               book["isFavorite"] = !book["isFavorite"];
//             });
//           },
//         ),
//       ),
//     );
//   }
// }
