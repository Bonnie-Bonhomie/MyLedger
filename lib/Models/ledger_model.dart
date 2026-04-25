
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'ledger_model.g.dart';

@HiveType(typeId: 3)
class LedgerModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String allocationId;

  @HiveField(2)
  late String categoryId;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late double amount;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  late String inputMethod; // 'manual' | 'scan' | 'upload'

  @HiveField(7)
  late String? imagePath;

  LedgerModel({
    String? id,
    required this.allocationId,
    required this.categoryId,
    required this.description,
    required this.amount,
    DateTime? date,
    this.inputMethod = 'manual',
    this.imagePath,
  }) {
    this.id = id ?? const Uuid().v4();
    this.date = date ?? DateTime.now();
  }
}
