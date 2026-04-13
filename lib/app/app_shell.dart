import 'package:flutter/material.dart';
import 'package:battletech_calc/features/gator/ui/gator_screen.dart';
import 'package:battletech_calc/features/dice_roller/ui/dice_roller_screen.dart';

// AppShell is the root layout of the app.
// It owns the bottom navigation bar and swaps screens based on which tab is selected.
// To add a new feature tab: add its screen to _screens and a new item to the BottomNavigationBar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Tracks which tab is currently selected. 0 = GATOR, 1 = Dice.
  int _selectedIndex = 0;

  // The list of screens that map to each tab by index.
  // Order here must match the order of items in BottomNavigationBar below.
  final List<Widget> _screens = [
    const GatorScreen(),
    const DiceRollerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the screen that matches the currently selected tab index.
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        // Highlights the currently selected tab.
        currentIndex: _selectedIndex,

        // When a tab is tapped, update _selectedIndex to switch screens.
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        // One item per tab. Icons and labels are shown in the nav bar.
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'GATOR'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Dice'),
        ],
      ),
    );
  }
}
