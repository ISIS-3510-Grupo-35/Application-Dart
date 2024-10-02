// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:application_dart/services/firebase_auth_services.dart';
import 'package:application_dart/models/global_vars.dart';
import 'package:application_dart/views/Login/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginFormComponent extends StatefulWidget {
  final VoidCallback onClose; // Callback to handle state update in parent

  const LoginFormComponent({super.key, required this.onClose});

  @override
  _LoginFormComponentState createState() => _LoginFormComponentState();
}

class _LoginFormComponentState extends State<LoginFormComponent> {
  // State variable to track whether the user is in "login" or "signup" mode
  String formType = "login";

  final FirebaseAuthServices _auth = FirebaseAuthServices();
  // Define separate controllers for the login form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of controllers when not needed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.83,
      color: const Color(0xFFF6E7D8),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF4B324),
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ),
          ),
          // Conditionally render login or signup form based on formType
          if (formType == "login")
            Center(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Image.asset(
                    'images/UniParkCircle.png',
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.20,
                  ),
                  const SizedBox(height: 16.0),
                  // Email TextField
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      style: const TextStyle(fontSize: 11.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Password TextField
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      style: const TextStyle(fontSize: 11.0),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Login Button
                    SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4B324),
                      ),
                      onPressed: () {
                        _signIn();
                      },
                      child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      ),
                    ),
                    ),
                  const SizedBox(height: 16.0),
                  // Create Account Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        formType = "signup"; // Switch to signup form
                      });
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Show SignupFormComponent if formType is "signup"
            SignupFormComponent(
              onBackToLogin: () {
                setState(() {
                  formType = "login"; // Switch back to login form
                });
              },
            ),
        ],
      ),
    );
  }
  void _signIn() async{
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);
    var uuid = user?.uid;
    GlobalVars().uid = uuid; 
    if(user != null){
      if (kDebugMode) {
        print("Sign up successful");
      }
      Navigator.pushNamed(context, '/home');
    } else {
      if (kDebugMode) {
        print("Sign up failed");
      }
    }
  }
}

