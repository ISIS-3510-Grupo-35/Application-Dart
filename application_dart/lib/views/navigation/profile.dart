import 'dart:typed_data';
import 'package:application_dart/view_models/userapp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/models/global_vars.dart';
import 'package:application_dart/services/connectivity.dart';
import 'package:application_dart/services/image_cache_service.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({Key? key}) : super(key: key);

  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  final ImageCacheService _imageCacheService = ImageCacheService();
  late String? _uid;
  final _userAppViewModel = UserAppViewModel();
  bool _isConnected = false;
  Uint8List? _noInternetImage;

  @override
  void initState() {
    super.initState();
    _uid = GlobalVars().uid;
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    // Listen for connectivity status changes
    _connectivityService.statusStream.listen((status) {
      setState(() {
        _isConnected = status;
      });
    });

    // Load "No Connection" image from SharedPreferences
    await _imageCacheService.downloadAndCacheImage(); // Download if not cached
    final cachedImage = await _imageCacheService.getCachedImage();
    setState(() {
      _noInternetImage = cachedImage;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _resetAppState();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print('Failed to log out: $e');
    }
  }

  void _resetAppState() {
    GlobalVars().uid = null;
    _userAppViewModel.clearUserApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFFF6E7D8),
      ),
      body: _isConnected
          ? FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users_android').doc(_uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User not found.'));
                }

                var userApp = UserApp.fromJson(snapshot.data!.data() as Map<String, dynamic>);

                return _buildProfileContent(userApp);
              },
            )
          : _buildNoConnectionWidget(),
    );
  }

  Widget _buildProfileContent(UserApp userApp) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFF6E7D8),
              child: userApp.email.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey.shade800,
                    )
                  : null,
            ),
            const SizedBox(height: 20),
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
                    _buildUserInfo('Password', '•' * 8),
                    _buildUserInfo('Driver Status', userApp.driver ? 'Yes' : 'No'),
                    _buildUserInfo('Account Balance', '\$${userApp.balance.toString()}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
    );
  }

  Widget _buildNoConnectionWidget() {
    return Container(
      color: const Color(0xFFF6E7D8), // Yellow background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_noInternetImage != null)
              Image.memory(
                _noInternetImage!,
                height: 100,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 20),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
