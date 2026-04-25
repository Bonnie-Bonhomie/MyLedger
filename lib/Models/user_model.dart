import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late bool isEmailVerified;

  @HiveField(4)
  late bool isFaceVerified;

  @HiveField(5)
  late DateTime createdAt;

  UserModel({
    String? id,
    required this.name,
    required this.email,
    this.isEmailVerified = false,
    this.isFaceVerified = false,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }
}
