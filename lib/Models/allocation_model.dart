import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'allocation_model.g.dart';

@HiveType(typeId: 1)
class AllocationModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late double spendLimit;

  @HiveField(4)
  late double totalSpent;

  @HiveField(5)
  late bool isRecurring;

  @HiveField(6)
  late String recurringType; // 'weekly' | 'monthly' | 'none'

  @HiveField(7)
  late bool notificationsEnabled;

  @HiveField(8)
  late DateTime createdAt;

  AllocationModel({
    String? id,
    required this.categoryId,
    required this.name,
    this.spendLimit = 0,
    this.totalSpent = 0,
    this.isRecurring = false,
    this.recurringType = 'none',
    this.notificationsEnabled = false,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }
}

