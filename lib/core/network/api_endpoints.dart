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
  static const String friendsRanking = '/users/friends';
  static const String addFriend = '/users/friends';
  
  // Weather endpoints
  static const String weather = '/weather';
  
  // Chat endpoints
  static const String chat = '/chat';
  
  // Weatherbit API
  static const String weatherbitBaseUrl = 'https://api.weatherbit.io/v2.0';
  static const String weatherbitApiKey = 'b608d9642fea4d118f5f680968e47e8a';
  static String weatherbitCurrent(double lat, double lon) =>
      '$weatherbitBaseUrl/current?lat=$lat&lon=$lon&key=$weatherbitApiKey&lang=es';
  
  // Helper methods
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
