import '../../domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.idUser,
    required super.dateEvent,
    required super.imgPath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      idUser: json['id_user'],
      dateEvent: DateTime.parse(json['date_event']),
      imgPath: json['img_path'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'date_event': dateEvent.toIso8601String(),
      'img_path': imgPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 