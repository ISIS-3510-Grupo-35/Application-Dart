// profile_component.dart
import 'package:application_dart/view_models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/models/global_vars.dart'; // Import your global variables file

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({Key? key}) : super(key: key);

  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String? _uid; // Local variable to store the uid
  final _userAppViewModel = UserAppViewModel();

  @override
  void initState() {
    super.initState();
    _uid = GlobalVars().uid; // Fetch the global UID value
  }

  // Function to reset GlobalVars and UserApp instances
  void _resetAppState() {
    // Reset the GlobalVars singleton instance
    GlobalVars().uid = null;

    // Reset the UserApp instance and other related variables
    _userAppViewModel.clearUserApp();
  }

  // Logout function to handle user sign out and reset state
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      // Reset the application state
      _resetAppState();

      // Navigate back to login or main screen after logout
      Navigator.of(context).pushReplacementNamed('/'); // Replace with your login screen route
    } catch (e) {
      print('Failed to log out: $e'); // Handle logout failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFFF6E7D8), // Updated yellow color for app bar
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users_android').doc(_uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found.'));
          }

          // Parse the Firestore document into the UserApp model
          var userApp = UserApp.fromJson(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Profile Picture with Icon
                  CircleAvatar(
                    radius: 60,
                    // backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Placeholder image path
                    backgroundColor: const Color(0xFFF6E7D8), // Updated background color
                    child: userApp.email.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey.shade800,
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  // User Info Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfo('Name', '${userApp.firstName} ${userApp.lastName}'),
                          _buildUserInfo('Email', userApp.email),
                          _buildUserInfo('Password', '•' * 8), // Display password as dots
                          _buildUserInfo('Driver Status', userApp.driver ? 'Yes' : 'No'),
                          _buildUserInfo('Account Balance', '\$${userApp.balance.toString()}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Actions
                  // ElevatedButton.icon(
                  //   onPressed: () {},
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.black, backgroundColor: const Color(0xFFF6E7D8), // Text color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12), // Rounded button
                  //     ),
                  //   ),
                  //   icon: const Icon(Icons.edit),
                  //   label: const Text('Edit Profile'),
                  // ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _logout, // Call logout function on press
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 1.5), // Stronger border color and width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.black), // Icon color updated to black
                    label: const Text('Log Out'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build individual user info sections with improved styling
  Widget _buildUserInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF4B324), // Updated label color to specified yellow
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
