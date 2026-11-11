import 'package:flutter/material.dart';
import 'main.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _profileRefresh = 0;
  final Set<int> _visited = {0};

  Widget _buildTab(int i) {
    switch (i) {
      case 0:
        return const WelcomeScreen();
      case 1:
        return const HomeScreen();
      case 2:
        return const SearchScreen();
      case 3:
        return const FavoritesScreen();
      default:
        return ProfileScreen(key: ValueKey(_profileRefresh));
    }
  }

  void _selectTab(int i) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index = i;
      _visited.add(i);
      if (i == 4) _profileRefresh++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: List.generate(
            5,
            (i) => _visited.contains(i) ? _buildTab(i) : const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}