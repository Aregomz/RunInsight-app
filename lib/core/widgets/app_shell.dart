import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = ModalRoute.of(context)?.settings.name ?? '';

    int currentIndex = switch (location) {
      final path when path.startsWith('/home') => 0,
      final path when path.startsWith('/coach') => 1,
      final path when path.startsWith('/social') => 2,
      final path when path.startsWith('/profile') => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/coach');
              break;
            case 2:
              context.go('/social');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF0C0C27),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_motorsports), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
