import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String emoji;

  @HiveField(3)
  late double totalSpend;

  @HiveField(4)
  late DateTime createdAt;

  CategoryModel({
    String? id,
    required this.name,
    this.emoji = '📦',
    this.totalSpend = 0,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }
}
