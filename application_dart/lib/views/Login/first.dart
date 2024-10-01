import 'package:application_dart/views/Login/form.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  bool _showLoginForm = false; // State variable to track the view

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4B324),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.01),
            Image.asset(
              'images/UniPark.png',
              width: screenWidth * 0.6,
              height: screenHeight * 0.15,
            ),
            SizedBox(height: screenHeight * 0.01),
            // Conditionally show either the initial view or the login form
            if (!_showLoginForm) _buildInitialView(screenHeight, screenWidth),
            if (_showLoginForm)
              LoginFormComponent(
                onClose: _handleLoginClose, // Pass the callback to close login
              ),
          ],
        ),
      ),
    );
  }

  // Callback function to update state and hide the login form
  void _handleLoginClose() {
    setState(() {
      _showLoginForm = false;
    });
  }

  // Initial view widget before button is pressed
  Widget _buildInitialView(double screenHeight, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        children: [
          SizedBox(height: screenHeight * 0.15),
          const Center(
            child: Text(
              'We thrive to make your parking experience easier',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Image.asset(
            'images/UniParkCircle.png',
            width: screenWidth * 0.6,
            height: screenHeight * 0.3,
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: screenWidth * 0.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6E7D8),
              ),
              onPressed: () {
                // Update the state to show the login form
                setState(() {
                  _showLoginForm = true;
                });
              },
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
