import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = ModalRoute.of(context)?.settings.name ?? '';

    int currentIndex = switch (location) {
      final path when path.startsWith('/ranking') => 0,
      final path when path.startsWith('/coach') => 1,
      final path when path.startsWith('/home') => 2,
      final path when path.startsWith('/stats') => 3,
      final path when path.startsWith('/profile') => 4,
      _ => 2,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/ranking');
              break;
            case 1:
              context.go('/coach');
              break;
            case 2:
              context.go('/home');
              break;
            case 3:
              context.go('/stats');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF0C0C27),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
