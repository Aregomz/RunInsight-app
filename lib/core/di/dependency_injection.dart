import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class DependencyInjection {
  static void init() {
    // Configurar datasources
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    
    // Configurar repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    
    // Configurar blocs
    final authBloc = AuthBloc(authRepository: authRepository);
    
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
} 