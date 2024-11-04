import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/models/global_vars.dart';
import 'package:application_dart/view_models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:application_dart/view_models/firebase_auth.dart';

class SignupFormComponent extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const SignupFormComponent({super.key, required this.onBackToLogin});

  @override
  _SignupFormComponentState createState() => _SignupFormComponentState();
}

class _SignupFormComponentState extends State<SignupFormComponent> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  final List<String> _dropdownOptions = ["Driver", "Parking Owner"];
  String? _selectedOption;
  final _FirebaseAuthViewModel = FirebaseAuthViewModel();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFFF6E7D8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Center(
              child: Column(
                children: [
                  _buildTextField(_firstNameController, 'First Name', Icons.person, screenWidth),
                  const SizedBox(height: 16.0),
                  _buildTextField(_lastNameController, 'Last Name', Icons.person, screenWidth),
                  const SizedBox(height: 16.0),
                  _buildTextField(_emailController, 'Email', Icons.email, screenWidth),
                  const SizedBox(height: 16.0),
                  _buildTextField(_passwordController, 'Password', Icons.lock, screenWidth, obscureText: true),
                  const SizedBox(height: 16.0),
                  _buildTextField(_confirmationController, 'Confirm Password', Icons.lock, screenWidth, obscureText: true),
                  const SizedBox(height: 16.0),
                  _buildDropdown(screenWidth),
                  const SizedBox(height: 16.0),
                  _buildCreateAccountButton(screenWidth),
                  const SizedBox(height: 16.0),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, double screenWidth, {bool obscureText = false}) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: screenWidth * 0.15,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        style: const TextStyle(fontSize: 11.0),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildDropdown(double screenWidth) {
    return SizedBox(
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
    );
  }

  Widget _buildCreateAccountButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4B324),
        ),
        onPressed: _signUp,
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.black,
        ),
      ),
    );
  }

  void _signUp() async {
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
    } else {
      if (kDebugMode) {
        print("Sign up failed");
      }
    }
  }
}
