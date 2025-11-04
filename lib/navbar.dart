import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/post_screen.dart';
import 'screens/events_screen.dart';
import 'screens/others.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({Key? key}) : super(key: key);

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ChatScreen(),
    const PostScreen(),
    const EventsScreen(),
    const OthersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 1))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home, color: Colors.red), 
            label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), 
            activeIcon: Icon(Icons.chat, color: Colors.red), 
            label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.add), 
            activeIcon: Icon(Icons.add, color: Colors.red), 
            label: 'Post'),
            BottomNavigationBarItem(icon: Icon(Icons.event_outlined), 
            activeIcon: Icon(Icons.event, color: Colors.red), 
            label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), 
            activeIcon: Icon(Icons.more_horiz, color: Colors.red), 
            label: 'Others'),
          ],
        ),
      ),
    );
  }
}
