import 'package:flutter/material.dart';
import '../map/map_screen_web.dart';
import '../trails/trails_screen.dart';
import '../profile/profile_screen.dart';
import '../pins/create_pin_screen_simple.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MapScreenWeb(),
    const TrailsScreen(),
    const CreatePinScreenSimple(),
    const ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Map',
    ),
    const NavigationDestination(
      icon: Icon(Icons.route_outlined),
      selectedIcon: Icon(Icons.route),
      label: 'Trails',
    ),
    const NavigationDestination(
      icon: Icon(Icons.add_location_outlined),
      selectedIcon: Icon(Icons.add_location),
      label: 'Create',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        elevation: 8,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
    );
  }
}
