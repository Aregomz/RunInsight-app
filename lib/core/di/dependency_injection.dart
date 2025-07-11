import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import '../../features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import '../../features/ranking/domain/repositories/ranking_repository.dart';
import '../../features/ranking/domain/usecases/get_ranking.dart';
import '../../features/ranking/domain/usecases/get_user_position.dart';
import '../../features/ranking/domain/usecases/add_friend.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../core/network/dio_client.dart';

class DependencyInjection {
  static void init() {
    // Configurar datasources
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final friendsRankingRemoteDataSource = FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance);
    
    // Configurar repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    final rankingRepository = FriendsRankingRepositoryImpl(
      remoteDataSource: friendsRankingRemoteDataSource,
    );
    
    // Configurar use cases
    final getRankingUseCase = GetRankingUseCase(rankingRepository);
    final getUserPositionUseCase = GetUserPosition(rankingRepository);
    
    // Configurar blocs
    final authBloc = AuthBloc(authRepository: authRepository);
    final rankingBloc = RankingBloc(
      getRankingUseCase: getRankingUseCase,
      getUserPosition: getUserPositionUseCase,
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
    return FriendsRankingRepositoryImpl(remoteDataSource: friendsRankingRemoteDataSource);
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

  static RankingBloc getRankingBloc() {
    return RankingBloc(
      getRankingUseCase: getGetRankingUseCase(),
      getUserPosition: getGetUserPositionUseCase(),
    );
  }
} 