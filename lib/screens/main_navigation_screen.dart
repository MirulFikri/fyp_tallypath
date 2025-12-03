import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_home_screen.dart';
import 'groups_screen.dart';
import 'savings_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainHomeScreen(),
    const GroupsScreen(),
    const SavingsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState(){
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, String? result) async {
        if (didPop) {
          return; // If the pop already happened, do nothing
        }
        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Exit'),
              content: Text('Are you sure you want to leave this page?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Stay
                  child: Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Leave
                  child: Text('Leave'),
                ),
              ],
            );
          },
        );
        if (shouldPop == true) {
          SystemNavigator.pop(); // Pop the current screen
        }
      },
      child: Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF00D4AA),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'Savings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      )
    );
  }
}
