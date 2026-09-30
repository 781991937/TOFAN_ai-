import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';
import '../screens/files_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/voice_screen.dart';

/// Primary application navigation shell.
///
/// Images are intentionally not a top-level product feature; the future
/// academy will expose AI capabilities through the academic workspace.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    ChatScreen(),
    VoiceScreen(),
    FilesScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Chat',
    ),
    NavigationDestination(
      icon: Icon(Icons.mic_none_outlined),
      selectedIcon: Icon(Icons.mic),
      label: 'Voice',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: 'Files',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
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
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations,
      ),
    );
  }
}
