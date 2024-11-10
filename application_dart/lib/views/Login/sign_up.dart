import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/view_models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application_dart/view_models/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isLoading = false;
  String? _errorMessage;

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
                  _buildTextField(_firstNameController, 'First Name',
                      Icons.person, screenWidth,
                      maxLength: 50),
                  const SizedBox(height: 16.0),
                  _buildTextField(_lastNameController, 'Last Name',
                      Icons.person, screenWidth,
                      maxLength: 50),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                      _emailController, 'Email', Icons.email, screenWidth,
                      maxLength: 100),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                      _passwordController, 'Password', Icons.lock, screenWidth,
                      obscureText: true),
                  const SizedBox(height: 16.0),
                  _buildTextField(_confirmationController, 'Confirm Password',
                      Icons.lock, screenWidth,
                      obscureText: true),
                  const SizedBox(height: 16.0),
                  _buildDropdown(screenWidth),
                  const SizedBox(height: 16.0),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  _buildCreateAccountButton(screenWidth),
                  const SizedBox(height: 16.0),
                  if (!_isLoading) // Hide Back to Login while loading
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

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, double screenWidth,
      {bool obscureText = false, int? maxLength}) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: screenWidth * 0.15,
      child: TextField(
        controller: controller,
        maxLength: maxLength, // Add the maxLength parameter here
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
          counterText: '', // Hide the counter text if needed
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
        onPressed: _isLoading ? null : _signUp, // Disable button when loading
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _signUp() async {
    // Check if all fields have values
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmationController.text.isEmpty ||
        _selectedOption == null) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmationController.text) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog("Password length should be at least 6.");
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
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
        await userAppViewModel.createUserApp(newUser, uuid);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', uuid);
        Navigator.pushNamed(context, '/home');
      } else {
        _showErrorDialog("Error creating account. Account already exist.");
      }
    } catch (e) {
        _showErrorDialog("An error occurred. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
