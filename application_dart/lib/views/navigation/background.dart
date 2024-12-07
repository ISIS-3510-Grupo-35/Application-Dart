// ignore_for_file: library_private_types_in_public_api

import 'package:application_dart/views/navigation/map.dart'; // Import your MapComponent
import 'package:application_dart/views/navigation/profile.dart';
import 'package:application_dart/views/navigation/reservation.dart';
import 'package:application_dart/views/navigation/search/search.dart';
import 'package:flutter/material.dart';

class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({super.key});

  @override
  _BackgroundScreenState createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  int _selectedIndex = 0; // State variable to track the selected index of the bottom navbar

  // List of widgets corresponding to each BottomNavigationBar item
  final List<Widget> _widgetOptions = <Widget>[
    MapComponent(), // Reference to MapComponent
    const ParkingLotList(), // Placeholder for Favorites screen
    const ReservationsScreen(),
    const ProfileComponent(), // Reference to ProfileComponent
  ];

  // Callback function to handle bottom navbar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4B324),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03), // Spacer at the top
          Center(
            child: Image.asset(
              'images/UniPark.png',
              width: screenWidth * 0.6, // 60% of screen width
              height: screenHeight * 0.10, // 10% of screen height
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Spacer below the image
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, size: 40, color: const Color(0xFFF6E7D8).withOpacity(0.8)),
                      const Icon(Icons.location_pin),
                    ],
                  )
                : const Icon(Icons.location_pin),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, size: 40, color: const Color(0xFFF6E7D8).withOpacity(0.8)),
                      const Icon(Icons.search),
                    ],
                  )
                : const Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, size: 40, color: const Color(0xFFF6E7D8).withOpacity(0.8)),
                      const Icon(Icons.local_parking),
                    ],
                  )
                : const Icon(Icons.local_parking),
            label: 'Reservation',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 3
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, size: 40, color: const Color(0xFFF6E7D8).withOpacity(0.8)),
                      const Icon(Icons.person),
                    ],
                  )
                : const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFF4B324),
        type: BottomNavigationBarType.fixed, // Ensure the background color is applied
        selectedLabelStyle: const TextStyle(color: Colors.black), // Change selected label color
        unselectedLabelStyle: const TextStyle(color: Colors.black), // Change unselected label color
      ),
    );
  }
}

// PlaceholderWidget for screens that are not yet implemented
class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
