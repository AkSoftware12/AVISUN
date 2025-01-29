import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsAndEventsScreen extends StatelessWidget {
  // Sample data for news and events
  final List<Map<String, dynamic>> newsAndEvents = [
    {
      "title": "School Annual Day Celebration",
      "description": "Join us for the annual day celebration on 25th February at 6 PM in the main auditorium.",
      "date": "25 Feb 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Science Exhibition 2025",
      "description": "Explore exciting projects and ideas by our students during the science exhibition.",
      "date": "12 March 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Art & Craft Workshop",
      "description": "A hands-on workshop for art enthusiasts on 15th March at the art studio.",
      "date": "15 March 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Parent-Teacher Meeting",
      "description": "Parents are invited to discuss the progress of their wards on 20th March.",
      "date": "20 March 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Inter-School Sports Meet",
      "description": "Cheer for our team at the upcoming inter-school sports competition.",
      "date": "5 April 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Inter-School Sports Meet",
      "description": "Cheer for our team at the upcoming inter-school sports competition.",
      "date": "5 April 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Inter-School Sports Meet",
      "description": "Cheer for our team at the upcoming inter-school sports competition.",
      "date": "5 April 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Inter-School Sports Meet",
      "description": "Cheer for our team at the upcoming inter-school sports competition.",
      "date": "5 April 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
    {
      "title": "Inter-School Sports Meet",
      "description": "Cheer for our team at the upcoming inter-school sports competition.",
      "date": "5 April 2025",
      "imageUrl": "https://img.freepik.com/free-vector/people-showcasing-different-types-ways-access-news_53876-43017.jpg?t=st=1738050735~exp=1738054335~hmac=f98108557e9e0ccd146a07bf5d53f3a81be14c91f019bd0392c1307adbfa8694&w=1060"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'News & Events',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            Text(
              "Stay Updated with the Latest",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // News and Events List
            Expanded(
              child: ListView.builder(
                itemCount: newsAndEvents.length,
                itemBuilder: (context, index) {
                  final item = newsAndEvents[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: Image.network(
                        item['imageUrl'],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        item['title'],
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['description'],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Date: ${item['date']}",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to a detailed news/event screen (optional)
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


