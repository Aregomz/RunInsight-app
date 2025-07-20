class Event {
  final int id;
  final int idUser;
  final DateTime dateEvent;
  final String imgPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.idUser,
    required this.dateEvent,
    required this.imgPath,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    final eventDate = DateTime(dateEvent.year, dateEvent.month, dateEvent.day);
    final today = DateTime(now.year, now.month, now.day);
    return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
  }

  bool get isToday {
    final now = DateTime.now();
    final eventDate = DateTime(dateEvent.year, dateEvent.month, dateEvent.day);
    final today = DateTime(now.year, now.month, now.day);
    return eventDate.isAtSameMomentAs(today);
  }

  // Getter para lista de imágenes (por defecto solo imgPath)
  List<String> get imgPaths => [imgPath];
} 