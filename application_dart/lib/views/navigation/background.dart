import 'package:flutter/material.dart';

class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({super.key});

  @override
  _BackgroundScreenState createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  int _selectedIndex = 0; // State variable to track the selected index of the bottom navbar

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
  backgroundColor: const Color(0xFFF4B324),
  body: SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start, // Align widgets vertically from the start
      crossAxisAlignment: CrossAxisAlignment.center, // Center children horizontally
      children: [
        SizedBox(height: screenHeight * 0.01), // Spacer at the top
        Center(
          child: Image.asset(
            'images/UniPark.png',
            width: screenWidth * 0.6, // 60% of screen width
            height: screenHeight * 0.15, // 15% of screen height
          ),
        ),
        SizedBox(height: screenHeight * 0.01), // Spacer below the image
      ],
    ),
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
                  Icon(Icons.circle, size: 40, color:  const Color(0xFFF6E7D8).withOpacity(0.8)),
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
                  Icon(Icons.circle, size: 40, color:  const Color(0xFFF6E7D8).withOpacity(0.8)),
                  const Icon(Icons.favorite_outline),
                ],
              )
            : const Icon(Icons.favorite_outline),
        label: 'Favorites',
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
  )
);

  }


  // Callback function to handle bottom navbar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
