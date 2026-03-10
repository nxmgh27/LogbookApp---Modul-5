import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel extends HiveObject {
  @HiveField(0)
  final String? idString;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final String owner;

  @HiveField(7)
  final bool isPublic;

  LogModel({
    String? idString,
    ObjectId? id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.createdAt,
    required this.owner,
    this.isPublic = false,
  }) : idString = idString ?? id?.toHexString();

  ObjectId? get id =>
      idString != null ? ObjectId.fromHexString(idString!) : null;

  Map<String, dynamic> toMap() {
    final oid = id ?? ObjectId();
    return {
      '_id': oid,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'createdAt': createdAt,
      'owner': owner,
      'isPublic': isPublic,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    String? hexId;
    if (rawId is ObjectId) {
      hexId = rawId.toHexString();
    } else if (rawId != null) {
      hexId = rawId.toString();
    }

    return LogModel(
      idString: hexId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] ?? 'Pribadi',
      createdAt: map['createdAt'] != null
          ? map['createdAt'].toString()
          : DateTime.now().toIso8601String(),
      owner: map['owner'] ?? 'unknown',
      isPublic: map['isPublic'] ?? false,
    );
  }
}
