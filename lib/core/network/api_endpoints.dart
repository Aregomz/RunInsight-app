class ApiEndpoints {
  static const String baseUrl = 'https://api-gateway-runinsight-production.up.railway.app';
  
  // Auth endpoints
  static const String login = '/users/login';
  static const String register = '/users';
  static const String users = '/users';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  
  // Training endpoints
  static const String trainings = '/trainings';
  static const String startTraining = '/trainings/start';
  static const String finishTraining = '/trainings/finish';
  
  // Ranking endpoints
  static const String ranking = '/ranking';
  static const String userPosition = '/ranking/position';
  
  // Weather endpoints
  static const String weather = '/weather';
  
  // Chat endpoints
  static const String chat = '/chat';
  
  // Helper methods
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
