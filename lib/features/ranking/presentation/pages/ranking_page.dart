import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import '../widgets/ranking_item.dart';
import '../widgets/user_ranking_position.dart';
import '../widgets/share_button.dart';
import 'package:go_router/go_router.dart';

class RankingUser {
  final String name;
  final double km;
  final int workouts;
  final bool isCurrentUser;
  RankingUser({
    required this.name,
    required this.km,
    required this.workouts,
    this.isCurrentUser = false,
  });

  double get avg => workouts == 0 ? 0 : km / workouts;
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareRanking(List<RankingUser> users) async {
    // Captura solo el widget de top 4 con título
    final image = await _screenshotController.captureFromWidget(
      Material(
        color: const Color(0xFF0C0C27),
        child: _Top4RankingShare(users: users),
      ),
      delay: const Duration(milliseconds: 100),
    );
    if (image != null) {
      await Share.shareXFiles([
        XFile.fromData(image, mimeType: 'image/png', name: 'ranking.png')
      ], text: '¡Mira mi ranking!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ejemplo de datos
    final List<RankingUser> users = [
      RankingUser(name: 'Luka Modric', km: 42.3, workouts: 8),
      RankingUser(name: 'Marta Ventura', km: 28.7, workouts: 6),
      RankingUser(name: 'Tú', km: 22.1, workouts: 5, isCurrentUser: true),
      RankingUser(name: 'Pelos Rangel', km: 20.3, workouts: 5),
      RankingUser(name: 'Otro Amigo', km: 18.0, workouts: 4),
      RankingUser(name: 'Más Amigos', km: 15.0, workouts: 3),
    ];

    // Ordena por promedio y desempata por entrenamientos
    users.sort((a, b) {
      final cmp = b.avg.compareTo(a.avg);
      if (cmp != 0) return cmp;
      return b.workouts.compareTo(a.workouts);
    });

    final int userIndex = users.indexWhere((u) => u.isCurrentUser);
    final bool userInTop4 = userIndex >= 0 && userIndex < 4;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Ranking de amigos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Compite con tus amigos runners',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    if (i < 4) {
                      return RankingItem(
                        position: i + 1,
                        name: users[i].name,
                        km: users[i].km,
                        workouts: users[i].workouts,
                        isCurrentUser: users[i].isCurrentUser,
                        isTop4: true,
                      );
                    } else if (!userInTop4 && i == userIndex) {
                      // Solo muestra la posición del usuario fuera del top 4
                      return UserRankingPosition(
                        position: i + 1,
                        name: users[i].name,
                        km: users[i].km,
                        workouts: users[i].workouts,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              ShareButton(
                onPressed: () => _shareRanking(users),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Top4RankingShare extends StatelessWidget {
  final List<RankingUser> users;
  const _Top4RankingShare({required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0C27),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ranking de amigos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compite con tus amigos runners',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < users.length && i < 4; i++)
            RankingItem(
              position: i + 1,
              name: users[i].name,
              km: users[i].km,
              workouts: users[i].workouts,
              isCurrentUser: users[i].isCurrentUser,
              isTop4: true,
            ),
        ],
      ),
    );
  }
}
