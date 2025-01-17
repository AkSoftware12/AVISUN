import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
      children: [
        Text(
          'Profile Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Styling the text
        ),
        SizedBox(height: 20), // Add spacing between the text and button
        CupertinoButton(
          color: Colors.blue, // Optional: Add a color to the button
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.white), // Ensure contrast
          ),
          onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
          },
        ),
      ],
    ),
  );
}
}
