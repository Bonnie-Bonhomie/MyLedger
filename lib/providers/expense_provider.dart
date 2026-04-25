import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_ledger/Models/allocation_model.dart';
import 'package:my_ledger/Models/category_model.dart';
import 'package:my_ledger/Models/ledger_model.dart';
import 'package:my_ledger/utils/constants/app_constant.dart';


class ExpenseProvider extends ChangeNotifier {
  late Box<CategoryModel> _categoryBox;
  late Box<AllocationModel> _allocationBox;
  late Box<LedgerModel> _receiptBox;

  List<CategoryModel> get categories => _categoryBox.values.toList();
  List<AllocationModel> get allocations => _allocationBox.values.toList();
  List<LedgerModel> get receipts =>
      _receiptBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  double get totalSpent =>
      _receiptBox.values.fold(0, (sum, r) => sum + r.amount);

  double get totalBudget =>
      _allocationBox.values.fold(0, (sum, a) => sum + a.spendLimit);

  void init() {
    _categoryBox = Hive.box<CategoryModel>(AppConstants.categoryBoxName);
    _allocationBox = Hive.box<AllocationModel>(AppConstants.allocationBoxName);
    _receiptBox = Hive.box<LedgerModel>(AppConstants.ledgerBoxName);

    // Seed default categories if empty
    if (_categoryBox.isEmpty) {
      for (final cat in AppConstants.categoryIcons) {
        final model = CategoryModel(
          name: cat['name'] as String,
          emoji: cat['icon'] as String,
        );
        _categoryBox.put(model.id, model);
      }
    }
    notifyListeners();
  }

  // Categories

  Future<void> addCategory(String name, String emoji) async {
    final cat = CategoryModel(name: name, emoji: emoji);
    await _categoryBox.put(cat.id, cat);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    // Also delete related allocations and receipts
    final relatedAllocs =
        _allocationBox.values.where((a) => a.categoryId == id).toList();
    for (final a in relatedAllocs) {
      final relatedReceipts =
          _receiptBox.values.where((r) => r.allocationId == a.id).toList();
      for (final r in relatedReceipts) await _receiptBox.delete(r.id);
      await _allocationBox.delete(a.id);
    }
    notifyListeners();
  }

  //Allocations

  List<AllocationModel> allocationsForCategory(String categoryId) =>
      _allocationBox.values
          .where((a) => a.categoryId == categoryId)
          .toList();

  Future<void> addAllocation({
    required String categoryId,
    required String name,
    double spendLimit = 0,
    bool isRecurring = false,
    String recurringType = 'none',
    bool notificationsEnabled = false,
  }) async {
    final alloc = AllocationModel(
      categoryId: categoryId,
      name: name,
      spendLimit: spendLimit,
      isRecurring: isRecurring,
      recurringType: recurringType,
      notificationsEnabled: notificationsEnabled,
    );
    await _allocationBox.put(alloc.id, alloc);
    notifyListeners();
  }

  Future<void> updateAllocation(AllocationModel alloc) async {
    await alloc.save();
    notifyListeners();
  }

  Future<void> deleteAllocation(String id) async {
    final relatedReceipts =
        _receiptBox.values.where((r) => r.allocationId == id).toList();
    for (final r in relatedReceipts) await _receiptBox.delete(r.id);
    await _allocationBox.delete(id);
    notifyListeners();
  }

  //Ledgers

  List<LedgerModel> receiptsForAllocation(String allocationId) =>
      _receiptBox.values
          .where((r) => r.allocationId == allocationId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<LedgerModel> receiptsForCategory(String categoryId) =>
      _receiptBox.values
          .where((r) => r.categoryId == categoryId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> addReceipt({
    required String allocationId,
    required String categoryId,
    required String description,
    required double amount,
    DateTime? date,
    String inputMethod = 'manual',
  }) async {
    final receipt = LedgerModel(
      allocationId: allocationId,
      categoryId: categoryId,
      description: description,
      amount: amount,
      date: date,
      inputMethod: inputMethod,
    );
    await _receiptBox.put(receipt.id, receipt);

    // Update allocation spent total
    final alloc = _allocationBox.get(allocationId);
    if (alloc != null) {
      alloc.totalSpent += amount;
      await alloc.save();
    }

    // Update category spend
    final cat = _categoryBox.get(categoryId);
    if (cat != null) {
      cat.totalSpend += amount;
      await cat.save();
    }

    notifyListeners();
  }

  Future<void> deleteReceipt(LedgerModel receipt) async {
    // Reverse the allocation/category totals
    final alloc = _allocationBox.get(receipt.allocationId);
    if (alloc != null) {
      alloc.totalSpent -= receipt.amount;
      if (alloc.totalSpent < 0) alloc.totalSpent = 0;
      await alloc.save();
    }
    final cat = _categoryBox.get(receipt.categoryId);
    if (cat != null) {
      cat.totalSpend -= receipt.amount;
      if (cat.totalSpend < 0) cat.totalSpend = 0;
      await cat.save();
    }
    await _receiptBox.delete(receipt.id);
    notifyListeners();
  }


  //Start
  Map<String, double> get spendByCategory {
    final result = <String, double>{};
    for (final cat in _categoryBox.values) {
      result[cat.name] = cat.totalSpend;
    }
    return result;
  }

  List<LedgerModel> get recentReceipts => receipts.take(10).toList();

  CategoryModel? categoryById(String id) => _categoryBox.get(id);
  AllocationModel? allocationById(String id) => _allocationBox.get(id);
}
