import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel extends HiveObject {
  // --- SESUAI MODUL LANGKAH 1.2 & 2.2 ---
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String authorId; // Sesuai Modul: Penanda siapa pembuatnya

  @HiveField(5)
  final String teamId; // Sesuai Modul: Penanda data milik kelompok mana

  // --- SESUAI MODUL TASK 5 (HOTS) ---
  @HiveField(6)
  final bool isPublic; 

  // --- SESUAI MODUL HOMEWORK (KATEGORI) ---
  @HiveField(7)
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.authorId,
    required this.teamId,
    this.isPublic = false,
    this.category = 'Pribadi',
  });

  Map<String, dynamic> toMap() => {
        '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
        'title': title,
        'description': description,
        'date': date,
        'authorId': authorId,
        'teamId': teamId,
        'isPublic': isPublic,
        'category': category,
      };

  factory LogModel.fromMap(Map<String, dynamic> map) {
    // Menangani _id dari MongoDB agar jadi String
    String? parsedId;
    if (map['_id'] is ObjectId) {
      parsedId = (map['_id'] as ObjectId).oid;
    } else if (map['_id'] != null) {
      parsedId = map['_id'].toString();
    }

    return LogModel(
      id: parsedId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? DateTime.now().toString(),
      authorId: map['authorId'] ?? 'unknown_user',
      teamId: map['teamId'] ?? 'no_team',
      isPublic: map['isPublic'] ?? false,
      category: map['category'] ?? 'Pribadi',
    );
  }
}