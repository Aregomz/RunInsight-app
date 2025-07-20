import '../../domain/entities/event.dart';

class EventModel extends Event {
  final List<String> imgPaths;

  EventModel({
    required super.id,
    required super.idUser,
    required super.dateEvent,
    required String imgPath,
    required super.createdAt,
    required super.updatedAt,
    List<String>? imgPaths,
  })  : imgPaths = imgPaths ?? [imgPath],
        super(imgPath: imgPath);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Soporta ambos formatos: img_path (string) y img_paths (lista)
    List<String> images = [];
    if (json['img_paths'] != null && json['img_paths'] is List) {
      images = List<String>.from(json['img_paths']);
    } else if (json['img_path'] != null && json['img_path'] is String) {
      images = [json['img_path']];
    }
    return EventModel(
      id: json['id'],
      idUser: json['id_user'],
      dateEvent: DateTime.parse(json['date_event']),
      imgPath: images.isNotEmpty ? images[0] : '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imgPaths: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'date_event': dateEvent.toIso8601String(),
      'img_path': imgPath,
      'img_paths': imgPaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 