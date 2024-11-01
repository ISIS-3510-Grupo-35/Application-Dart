// ignore_for_file: library_private_types_in_public_api

import 'package:application_dart/views/widgets/wrapper_connectivity.dart';
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4B324),
        body: ConnectivityWrapper(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Image.asset(
                          'images/UniPark.png',
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        if (!_showLoginForm) _buildInitialView(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
                        if (_showLoginForm)
                          LoginFormComponent(
                            onClose: _handleLoginClose,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
