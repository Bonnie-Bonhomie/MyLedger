
class AppConstants {
  static const String userBoxName = 'userBox';
  static const String categoryBoxName = 'categoryBox';
  static const String allocationBoxName = 'allocationBox';
  static const String ledgerBoxName = 'ledgerBox';
  static const String settingsBoxName = 'settingsBox';

  static const List<String> defaultCategories = [
    'Mobility',
    'Food & Dining',
    'Housing',
    'Entertainment',
    'Health',
    'Shopping',
    'Utilities',
    'Education',
  ];

  static const List<Map<String, dynamic>> categoryIcons = [
    {'name': 'Mobility', 'icon': '🚗'},
    {'name': 'Food & Dining', 'icon': '🍔'},
    {'name': 'Housing', 'icon': '🏠'},
    {'name': 'Entertainment', 'icon': '🎬'},
    {'name': 'Health', 'icon': '💊'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Utilities', 'icon': '⚡'},
    {'name': 'Education', 'icon': '📚'},
  ];
}