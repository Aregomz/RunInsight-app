import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:runinsight/features/ranking/presentation/bloc/ranking_bloc.dart';
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_ranking.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_user_position.dart';
import 'package:runinsight/features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import 'package:runinsight/features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import 'package:runinsight/core/network/dio_client.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
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

// Extensión para convertir RankingUserEntity a RankingUser
extension RankingUserEntityExtension on RankingUserEntity {
  RankingUser toRankingUser({required bool isCurrentUser}) {
    return RankingUser(
      name: name,
      km: totalKm,
      workouts: trainings,
      isCurrentUser: isCurrentUser,
    );
  }
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
        XFile.fromData(image, mimeType: 'image/png', name: 'ranking.png'),
      ], text: '¡Mira mi ranking!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = UserService.getUserId()?.toString() ?? '1';
        return RankingBloc(
          getRankingUseCase: GetRankingUseCase(FriendsRankingRepositoryImpl(
            remoteDataSource: FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance),
          )),
          getUserPosition: GetUserPosition(FriendsRankingRepositoryImpl(
            remoteDataSource: FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance),
          )),
        )..add(LoadRankingRequested(userId));
      },
      child: BlocBuilder<RankingBloc, RankingState>(
        builder: (context, state) {
          if (state is RankingLoading) {
            return _buildLoadingState();
          } else if (state is RankingLoaded) {
            return _buildLoadedState(context, state);
          } else if (state is RankingError) {
            return _buildErrorState(context, state);
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
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
        title: const Text(
          'Ranking de amigos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6A00),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, RankingError state) {
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
        title: const Text(
          'Ranking de amigos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final userId = UserService.getUserId()?.toString() ?? '1';
                context.read<RankingBloc>().add(LoadRankingRequested(userId));
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, RankingLoaded state) {
    // Convertir entidades a RankingUser
    final List<RankingUser> users = state.entries.map((entity) {
      final isCurrentUser = entity.id == state.userId;
      return entity.toRankingUser(isCurrentUser: isCurrentUser);
    }).toList();

    // Si no hay amigos, mostrar mensaje
    if (users.isEmpty) {
      return _buildEmptyState(context);
    }

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
        title: const Text(
          'Ranking de amigos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              ShareButton(onPressed: () => _shareRanking(users)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
        title: const Text(
          'Ranking de amigos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline,
                color: Colors.white70,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No tienes amigos aún',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Comparte tu link de invitación para agregar amigos y competir en el ranking',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ShareButton(
                onPressed: () => _shareInvitationLink(context),
                text: 'Compartir Link de Invitación',
                icon: Icons.share,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareInvitationLink(BuildContext context) {
    try {
      final invitationLink = UserService.generateInvitationLink();
      final userName = UserService.getCurrentUserName() ?? 'un amigo';
      
      Share.share(
        '¡Hola! $userName te invita a competir en RunInsight. Únete usando este link: $invitationLink',
        subject: 'Invitación a RunInsight',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
