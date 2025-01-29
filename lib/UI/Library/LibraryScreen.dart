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


