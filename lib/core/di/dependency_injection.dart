import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import '../../features/ranking/data/datasources/badges_remote_datasource.dart';
import '../../features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import '../../features/ranking/domain/repositories/ranking_repository.dart';
import '../../features/ranking/domain/usecases/get_ranking.dart';
import '../../features/ranking/domain/usecases/get_user_position.dart';
import '../../features/ranking/domain/usecases/get_user_badges.dart';
import '../../features/ranking/domain/usecases/add_friend.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../core/network/dio_client.dart';
import '../../features/ia_coach/data/datasources/ia_coach_remote_datasource_impl.dart';
import '../../features/ia_coach/data/repositories/ia_coach_repository_impl.dart';
import '../../features/ia_coach/domain/usecases/get_ia_predictions_usecase.dart';
import '../../features/ia_coach/presentation/bloc/ia_coach_bloc.dart';
import '../../core/services/gemini_api_service.dart';

class DependencyInjection {
  static void init() {
    // Configurar datasources
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final friendsRankingRemoteDataSource = FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance);
    final badgesRemoteDataSource = BadgesRemoteDataSourceImpl();
    
    // Configurar repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    final rankingRepository = FriendsRankingRepositoryImpl(
      remoteDataSource: friendsRankingRemoteDataSource,
      badgesRemoteDataSource: badgesRemoteDataSource,
    );
    
    // Configurar use cases
    final getRankingUseCase = GetRankingUseCase(rankingRepository);
    final getUserPositionUseCase = GetUserPosition(rankingRepository);
    final getUserBadgesUseCase = GetUserBadges(repository: rankingRepository);
    
    // Configurar blocs
    final authBloc = AuthBloc(authRepository: authRepository);
    final rankingBloc = RankingBloc(
      getRankingUseCase: getRankingUseCase,
      getUserPosition: getUserPositionUseCase,
      getUserBadges: getUserBadgesUseCase,
    );
    
    // Aquí podrías usar un service locator como GetIt para registrar las dependencias
    // Por ahora, las dependencias se pasan directamente en los constructores
  }
  
  // Métodos helper para obtener instancias
  static AuthRepository getAuthRepository() {
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    return AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  }
  
  static AuthBloc getAuthBloc() {
    return AuthBloc(authRepository: getAuthRepository());
  }

  static RankingRepository getRankingRepository() {
    final friendsRankingRemoteDataSource = FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance);
    final badgesRemoteDataSource = BadgesRemoteDataSourceImpl();
    return FriendsRankingRepositoryImpl(
      remoteDataSource: friendsRankingRemoteDataSource,
      badgesRemoteDataSource: badgesRemoteDataSource,
    );
  }

  static GetRankingUseCase getGetRankingUseCase() {
    return GetRankingUseCase(getRankingRepository());
  }

  static GetUserPosition getGetUserPositionUseCase() {
    return GetUserPosition(getRankingRepository());
  }

  static AddFriendUseCase getAddFriendUseCase() {
    return AddFriendUseCase(getRankingRepository());
  }

  static GetUserBadges getGetUserBadgesUseCase() {
    return GetUserBadges(repository: getRankingRepository());
  }

  static RankingBloc getRankingBloc() {
    return RankingBloc(
      getRankingUseCase: getGetRankingUseCase(),
      getUserPosition: getGetUserPositionUseCase(),
      getUserBadges: GetUserBadges(repository: getRankingRepository()),
    );
  }

  // Profile dependencies
  static ProfileRepository getProfileRepository() {
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl();
    return ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);
  }

  static UpdateProfileUseCase getUpdateProfileUseCase() {
    return UpdateProfileUseCase(repository: getProfileRepository());
  }

  // IA Coach dependencies
  static GeminiApiService getGeminiApiService() {
    return GeminiApiService();
  }

  static IaCoachRemoteDatasourceImpl getIaCoachRemoteDatasource() {
    return IaCoachRemoteDatasourceImpl(geminiApiService: getGeminiApiService());
  }

  static IaCoachRepositoryImpl getIaCoachRepository() {
    return IaCoachRepositoryImpl(remoteDatasource: getIaCoachRemoteDatasource());
  }

  static GetIaPredictionsUseCase getIaPredictionsUseCase() {
    return GetIaPredictionsUseCase(getIaCoachRepository());
  }

  static IaCoachBloc getIaCoachBloc() {
    return IaCoachBloc(getPredictions: getIaPredictionsUseCase());
  }
} 