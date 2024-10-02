// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/models/global_vars.dart';
import 'package:application_dart/view_models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:application_dart/view_models/firebase_auth.dart';

class SignupFormComponent extends StatefulWidget {
  final VoidCallback onBackToLogin; // Callback to switch back to login view

  const SignupFormComponent({super.key, required this.onBackToLogin});

  @override
  _SignupFormComponentState createState() => _SignupFormComponentState();
}

class _SignupFormComponentState extends State<SignupFormComponent> {
  // Define separate controllers for the signup form
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();


  // Dropdown options and selected value specific to signup form
  final List<String> _dropdownOptions = ["Driver", "Parking Owner"];
  String? _selectedOption;

  final _FirebaseAuthViewModel = FirebaseAuthViewModel();

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.75,
      color: const Color(0xFFF6E7D8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Column(
                children: [
                  // First Name Field
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      style: const TextStyle(fontSize: 11.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Last Name Field
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      style: const TextStyle(fontSize: 11.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Email Field
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
                  // Password Field
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
                  //Confirm Password
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _confirmationController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      style: const TextStyle(fontSize: 11.0),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Dropdown for selection
                    SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.15,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                      labelText: 'I am a ... ',
                      border: OutlineInputBorder(),
                      ),
                      value: _selectedOption,
                      onChanged: (newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                      },
                      items: _dropdownOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                        option,
                        style: const TextStyle(fontSize: 11.0),
                        ),
                      );
                      }).toList(),
                    ),
                    ),
                  const SizedBox(height: 16.0),
                  // Create Account Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4B324),
                      ),
                      onPressed: () {
                        // Handle create account logic here

                        _signUp();
                      },
                      child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Back to Login Button
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
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
    void _signUp() async{
    String email = _emailController.text;
    String password = _passwordController.text;

    await _FirebaseAuthViewModel.register(email, password);
    User? user = _FirebaseAuthViewModel.currentUser;

    if (user != null) {
      var uuid = user.uid;
      UserApp newUser = UserApp.fromJson({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': email,
        'password': password,
        'driver': _selectedOption == 'Driver' ? true : false,
        'balance': 0.0,
        'id': uuid,
      });
      UserAppViewModel userAppViewModel = UserAppViewModel();
      userAppViewModel.createUserApp(newUser, uuid);
      GlobalVars().uid = uuid; 
      Navigator.pushNamed(context, '/home');
    }
    else {
      if (kDebugMode) {
        print("Sign up failed");
      }
    }
  }
}
