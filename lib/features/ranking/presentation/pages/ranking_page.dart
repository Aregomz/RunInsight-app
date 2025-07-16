import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:runinsight/features/ranking/presentation/bloc/ranking_bloc.dart';
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_ranking.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_user_position.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_user_badges.dart';
import 'package:runinsight/features/ranking/domain/usecases/add_friend.dart';
import 'package:runinsight/core/di/dependency_injection.dart';
import 'package:runinsight/features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import 'package:runinsight/features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import 'package:runinsight/features/ranking/data/datasources/badges_remote_datasource.dart';
import 'package:runinsight/core/network/dio_client.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
import '../widgets/ranking_item.dart';
import '../widgets/user_ranking_position.dart';
import '../widgets/share_button.dart';
import '../widgets/badges_tab.dart';
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
  bool _showRanking = true; // true = ranking, false = insignias
  late RankingBloc _rankingBloc;

  @override
  void initState() {
    super.initState();
    final userId = UserService.getUserId()?.toString() ?? '1';
    final badgesDataSource = BadgesRemoteDataSourceImpl();
    final repository = FriendsRankingRepositoryImpl(
      remoteDataSource: FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance),
      badgesRemoteDataSource: badgesDataSource,
    );
    
    _rankingBloc = RankingBloc(
      getRankingUseCase: GetRankingUseCase(repository),
      getUserPosition: GetUserPosition(repository),
      getUserBadges: GetUserBadges(repository: repository),
    );
    _rankingBloc.add(LoadRankingRequested(userId));
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }

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
        return _rankingBloc;
      },
      child: BlocBuilder<RankingBloc, RankingState>(
        builder: (context, state) {
          if (state is RankingLoading) {
            return _buildLoadingState();
          } else if (state is BadgesLoading) {
            return _buildBadgesLoadingState();
          } else if (state is RankingLoaded && _showRanking) {
            return _buildLoadedState(context, state);
          } else if (state is BadgesLoaded && !_showRanking) {
            return _buildBadgesState(context, state);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Ranking de amigos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            _buildToggleButton(),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6A00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesLoadingState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
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
                'Mis Insignias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            _buildToggleButton(),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6A00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesState(BuildContext context, BadgesLoaded state) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
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
                'Mis Insignias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            _buildToggleButton(),
            Expanded(
              child: BadgesTab(
                badges: state.badges,
                isLoading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, RankingError state) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
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
            _buildToggleButton(),
            Expanded(
              child: Center(
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
                        _rankingBloc.add(LoadRankingRequested(userId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, RankingLoaded state) {
    // Obtener el ID del usuario actual
    final currentUserId = UserService.getUserId()?.toString();
    // Convertir entidades a RankingUser usando solo la info del backend
    final List<RankingUser> users = state.entries.map((entity) {
      return entity.toRankingUser(isCurrentUser: entity.id == currentUserId);
    }).toList();

    // Si no hay amigos, mostrar mensaje
    if (users.isEmpty) {
      return _buildEmptyState(context);
    }

    final int userIndex = users.indexWhere((u) => u.isCurrentUser);
    final bool userInTop4 = userIndex >= 0 && userIndex < 4;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Ranking de amigos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            _buildToggleButton(),
            Expanded(
              child: SafeArea(
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
                                highlightColor: users[i].isCurrentUser ? const Color(0xFFFF6A00) : null,
                              );
                            } else if (!userInTop4 && i == userIndex) {
                              // Solo muestra la posición del usuario fuera del top 4
                              return UserRankingPosition(
                                position: i + 1,
                                name: users[i].name,
                                km: users[i].km,
                                workouts: users[i].workouts,
                                highlightColor: users[i].isCurrentUser ? const Color(0xFFFF6A00) : null,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Botón Agregar Amigo (azul, destacado)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _shareInvitationLink(context),
                          icon: const Icon(Icons.person_add, color: Colors.white, size: 22),
                          label: const Text(
                            'Agregar Amigo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2979FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: Color(0xFF2979FF).withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botón Compartir Ranking (más delgado, naranja)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _shareRanking(users),
                          icon: const Icon(Icons.ios_share, color: Colors.white, size: 22),
                          label: const Text(
                            'Compartir Mi Ranking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
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
            _buildToggleButton(),
            Expanded(
              child: SafeArea(
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
            ),
          ],
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

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController friendIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181B23),
          title: const Text(
            'Agregar Amigo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa el ID del usuario que quieres agregar como amigo:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: friendIdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ID del usuario',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF0C0C27),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6A00), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final friendId = int.tryParse(friendIdController.text);
                if (friendId != null) {
                  Navigator.of(context).pop();
                  await _addFriend(context, friendId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un ID válido'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFriend(BuildContext context, int friendId) async {
    try {
      final currentUserId = UserService.getUserId();
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para agregar amigos'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Evitar agregarse a sí mismo como amigo
      if (currentUserId == friendId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes agregarte a ti mismo como amigo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final addFriendUseCase = DependencyInjection.getAddFriendUseCase();
      await addFriendUseCase(currentUserId, friendId);
      
      // Recargar el ranking después de agregar el amigo
      final userId = UserService.getUserId()?.toString() ?? '1';
      _rankingBloc.add(LoadRankingRequested(userId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Amigo agregado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar amigo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildToggleButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF181B23),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6A00).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleOption(
              text: 'Ranking',
              icon: Icons.leaderboard,
              isSelected: _showRanking,
              onTap: () {
                if (!_showRanking) {
                  setState(() {
                    _showRanking = true;
                  });
                  final userId = UserService.getUserId()?.toString() ?? '1';
                  _rankingBloc.add(LoadRankingRequested(userId));
                }
              },
            ),
            _buildToggleOption(
              text: 'Insignias',
              icon: Icons.emoji_events,
              isSelected: !_showRanking,
              onTap: () {
                if (_showRanking) {
                  setState(() {
                    _showRanking = false;
                  });
                  final userId = UserService.getUserId() ?? 1;
                  _rankingBloc.add(LoadBadgesRequested(userId));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6A00) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
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
