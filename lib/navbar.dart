import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/post_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/others.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

final pagesProvider = Provider<List<Widget>>((ref) {
  return const [
    HomeScreen(),
    ChatPage(),
    PostScreen(),
    ProfileScreen(),
    OthersScreen(),
  ];
});

final navIconsProvider = Provider<Map<String, List<IconData>>>((ref) {
  return {
    'icons': const [
      Icons.home_outlined,
      Icons.chat_outlined,
      Icons.add,
      Icons.person_outlined,
      Icons.more_horiz_outlined,
    ],
    'activeIcons': const [
      Icons.home,
      Icons.chat,
      Icons.add,
      Icons.person,
      Icons.more_horiz,
    ],
  };
});

class NavBarPage extends ConsumerStatefulWidget {
  const NavBarPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends ConsumerState<NavBarPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  double navbarBottomPosition = -120; // start hidden

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Slide-in navbar animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        navbarBottomPosition = 0;
      });
    });

    // System nav buttons behind
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final pages = ref.watch(pagesProvider);
    final navIcons = ref.watch(navIconsProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            children: pages,
          ),

          // Glass Navbar with slide-in animation
 AnimatedPositioned(
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
  left: 16,
  right: 16,
  bottom: -25, // <- distance from bottom of screen (adjust as needed)
  child: ClipRRect(
    borderRadius: BorderRadius.circular(100), // fully rounded
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        height: 122,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.35),
              Colors.black.withOpacity(0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (int index) {
            HapticFeedback.lightImpact();
            ref.read(navigationIndexProvider.notifier).state = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: List.generate(5, (index) {
            final icons = navIcons['icons']!;
            final activeIcons = navIcons['activeIcons']!;
            final isSelected = currentIndex == index;

            return BottomNavigationBarItem(
              icon: _GlassNavIcon(
                icon: icons[index],
                activeIcon: activeIcons[index],
                isActive: isSelected,
              ),
              label: '',
            );
          }),
        ),
      ),
    ),
  ),
),

       ],
      ),
    );
  }
}

class _GlassNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;

  const _GlassNavIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? Colors.white : Colors.white54,
        size: 28,
      ),
    );
  }
}
