import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'utils/upgrader_config.dart';

// This is a test page to verify upgrader is working
// Only use this during development/testing
class TestUpgraderPage extends StatelessWidget {
  const TestUpgraderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: UpgraderConfig.getTestUpgrader(), // Uses test upgrader with debug enabled
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Upgrader'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Upgrader Test Page',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'This page is used to test the upgrader functionality.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'If upgrader is working, you should see an update dialog appear.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
