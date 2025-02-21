import 'package:flutter/material.dart';
import 'dart:async';

class TimelineWithDot extends StatefulWidget {
  @override
  _TimelineWithDotState createState() => _TimelineWithDotState();
}

class _TimelineWithDotState extends State<TimelineWithDot> {
  double dotPosition = 0.0;
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    updateDotPosition();
    Timer.periodic(Duration(minutes: 1), (timer) {
      updateDotPosition();
    });
  }

  void updateDotPosition() {
    DateTime now = DateTime.now();
    double totalMinutes = 24 * 60; // Total minutes in a day
    int currentMinutes = now.hour * 60 + now.minute;

    // Timeline ki height ke hisaab se position calculate karna
    double maxHeight = 300.0; // Change this according to your timeline height
    double newPosition = (currentMinutes / totalMinutes) * maxHeight;

    setState(() {
      dotPosition = newPosition;
      currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}"; // HH:MM format
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Vertical Line
            Positioned(
              left: 80,
              top: 10,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.blue[300],
              ),
            ),
            // Dot with Time
            Positioned(
              left: 75,
              top: 10 + dotPosition, // Dynamic Position
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Time Text
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Red Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red, // Dot Color
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
