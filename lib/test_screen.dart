import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PinQuest - Test'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_pin,
              size: 100,
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              'PinQuest',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'App is working!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This is a simple test screen to verify\nthat the Flutter app is running correctly.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
