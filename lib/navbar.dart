import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/post_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/others.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({Key? key}) : super(key: key);

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [
    HomeScreen(),
    ChatScreen(),
    PostScreen(),
    ProfileScreen(),
    OthersScreen(),
  ];

  final List<Color> _navColors = const [
    Color(0xFFAEDFF7), 
    Color.fromARGB(255, 161, 204, 245), 
    Color(0xFFAEDFF7), 
    Color.fromARGB(255, 161, 204, 245), 
    Color(0xFFAEDFF7), 
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),

     
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  color: _navColors[_currentIndex],
  padding: const EdgeInsets.only(top: 10), 
  height: 115, 
  child: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (int index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    },
    elevation: 0,
    backgroundColor: Colors.transparent,
    selectedItemColor: const Color.fromARGB(255, 40, 86, 95),
    unselectedItemColor: const Color.fromARGB(255, 137, 141, 144),
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    items: List.generate(5, (index) {
      const icons = [
        Icons.home_outlined,
        Icons.chat_outlined,
        Icons.add,
        Icons.person_outlined,
        Icons.more_horiz_outlined,
      ];
      const activeIcons = [
        Icons.home,
        Icons.chat,
        Icons.add,
        Icons.person,
        Icons.more_horiz,
      ];
      const labels = ['Home', 'Chat', 'Post', 'Profile', 'Others'];

      final isSelected = _currentIndex == index;

      return BottomNavigationBarItem(
        icon: _BouncyIcon(
          icon: icons[index],
          activeIcon: activeIcons[index],
          isActive: isSelected,
        ),
        label: labels[index],
      );
    }),
  ),
),

          ),
          Positioned(
            bottom: 6,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              alignment: _indicatorAlignment(_currentIndex),
              child: Container(
                height: 5,
                width: 24,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 91, 118, 176),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _indicatorAlignment(int index) {
    switch (index) {
      case 0:
        return const Alignment(-1.0, 0);
      case 1:
        return const Alignment(-0.5, 0);
      case 2:
        return const Alignment(0.0, 0);
      case 3:
        return const Alignment(0.5, 0);
      case 4:
        return const Alignment(1.0, 0);
      default:
        return Alignment.center;
    }
  }
}


class _BouncyIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;

  const _BouncyIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isActive ? -10.0 : 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Transform.scale(
            scale: isActive ? 1.25 : 1.0,
            child: Icon(
              isActive ? activeIcon : icon,
              color:
                  isActive ? const Color.fromARGB(255, 6, 67, 188) : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
