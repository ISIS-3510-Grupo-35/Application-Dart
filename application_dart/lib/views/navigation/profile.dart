// profile_component.dart
import 'package:application_dart/services/connectivity.dart'; 
import 'package:application_dart/view_models/userapp.dart';
import 'package:application_dart/models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({Key? key}) : super(key: key);

  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _uid = '';
  final _userAppViewModel = UserAppViewModel();

  UserApp? _cachedUserApp; // To store the fetched user data once

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = prefs.getString('user_uid') ?? '';
    });
  }

  void _resetAppState() {
    _userAppViewModel.clearUserApp();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      Navigator.pushReplacementNamed(context, '/');
      _resetAppState();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print('Failed to log out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

    // First, we wrap everything in a StreamBuilder to listen to connectivity
    return StreamBuilder<bool>(
      stream: connectivityService.statusStream,
      initialData: connectivityService.isConnected,
      builder: (context, connectivitySnapshot) {
        final isConnected = connectivitySnapshot.data ?? true;

        // If we don't have a user ID yet, just show a loader
        if (_uid.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If we haven't yet loaded _cachedUserApp, we need to fetch data
        // from Firestore once. After that, we rely solely on _cachedUserApp.
        if (_cachedUserApp == null) {
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(_uid).get(),
            builder: (context, snapshot) {
              // If no connectivity and still waiting for data, we cannot load user data
              if (!isConnected && snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: const Center(
                    child: Text(
                      'No internet connection. Unable to load user data.',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // If connected but still loading data, show a loader
              if (snapshot.connectionState == ConnectionState.waiting && isConnected) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If there's an error
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              // If no user data found
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Scaffold(
                  body: Center(child: Text('User not found.')),
                );
              }

              // Successfully fetched data: store it in _cachedUserApp
              _cachedUserApp = UserApp.fromJson(snapshot.data!.data() as Map<String, dynamic>);

              // Now build the UI from _cachedUserApp
              return _buildProfileUI(isConnected);
            },
          );
        } else {
          // We already have cached data, just build the UI from it.
          return _buildProfileUI(isConnected);
        }
      },
    );
  }

  Widget _buildProfileUI(bool isConnected) {
    final userApp = _cachedUserApp!;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo('Name', '${userApp.firstName} ${userApp.lastName}'),
                      _buildUserInfo('Email', userApp.email),
                      _buildUserInfo('Driver Status', userApp.driver ? 'Yes' : 'No'),
                      if (isConnected)
                        _buildUserInfo('Account Balance', '\$${userApp.balance.toString()}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // If connected, show all features
              if (isConnected) ...[
                OutlinedButton.icon(
                  onPressed: _showChangePasswordSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lock, color: Colors.red),
                  label: const Text('Change Password'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _showAddBalanceSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.account_balance_wallet, color: Colors.green),
                  label: const Text('Add to Balance'),
                ),
                const SizedBox(height: 10),
              ] else ...[
                // Offline mode: limited functionality
                const Text(
                  'Offline mode: Some features are unavailable.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              color: Color(0xFFF4B324),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Validate all fields
                        if (currentPasswordController.text.isEmpty ||
                            newPasswordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          setState(() {
                            errorMessage = 'All fields are required.';
                          });
                          return;
                        }

                        // Check if new password matches confirm password
                        if (newPasswordController.text == confirmPasswordController.text) {
                          if (newPasswordController.text.length < 6) {
                            setState(() {
                              errorMessage = 'New password must be at least 6 characters long.';
                            });
                          } else {
                            Map<bool, String> response =
                                await _userAppViewModel.changePassword(
                                    currentPasswordController.text,
                                    newPasswordController.text);

                            if (response.keys.first) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response.values.first),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setState(() {
                                errorMessage = response.values.first;
                              });
                            }
                          }
                        } else {
                          setState(() {
                            errorMessage = 'New passwords do not match. Please try again.';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBalanceSheet() {
    TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add to Balance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  int amount = int.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  } else {
                    _userAppViewModel.addBalance(amount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Balance added successfully.'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Update local model balance
                    UserApp userApp = _cachedUserApp!;
                    userApp.balance += amount;
                    setState(() {
                      _cachedUserApp = userApp;
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Add Balance',
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }
}
