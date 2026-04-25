import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ledger/Models/category_model.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/allocation_tile.dart';
import 'package:my_ledger/utils/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';


class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: expense.categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.onSurfaceMuted, size: 64),
                  const SizedBox(height: 16),
                  Text('No categories yet',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first category',
                      style: TextStyle(color: AppColors.onSurfaceMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expense.categories.length,
              itemBuilder: (_, i) => _CategoryCard(
                category: expense.categories[i],
              ),
            ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String emoji = '📦';
    final emojiOptions = ['📦', '🚗', '🍔', '🏠', '🎬', '💊', '🛍️', '⚡', '📚', '✈️', '💻', '🎮'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Category',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: emojiOptions.map((e) => GestureDetector(
                  onTap: () => setS(() => emoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: emoji == e
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: emoji == e ? AppColors.primary : Colors.white12,
                      ),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    await context.read<ExpenseProvider>().addCategory(
                        nameCtrl.text.trim(), emoji);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Create Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();
    final allocations = expense.allocationsForCategory(category.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(category.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${allocations.length} allocations • ${formatCurrency(category.totalSpend)} spent',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
          children: [
            ...allocations.map((a) => AllocationTile(
                  allocation: a,
                  categoryId: category.id,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () => _showAddAllocationDialog(context, category.id),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Allocation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Delete Category'),
        content: const Text(
            'This will delete all allocations and receipts in this category.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExpenseProvider>().deleteCategory(category.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddAllocationDialog(BuildContext context, String categoryId) {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    bool isRecurring = false;
    String recurringType = 'none';
    bool notifications = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Allocation',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Allocation Name',
                    hintText: 'e.g. Travel, Vehicle',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Spend Limit (₦)',
                    prefixIcon: Icon(Icons.money_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recurring'),
                  subtitle: const Text('Weekly or monthly reset'),
                  value: isRecurring,
                  onChanged: (v) => setS(() => isRecurring = v),
                  activeColor: AppColors.primary,
                ),
                if (isRecurring) ...[
                  Row(
                    children: ['weekly', 'monthly'].map((type) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => recurringType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: recurringType == type
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: recurringType == type
                                      ? AppColors.primary
                                      : Colors.white12),
                            ),
                            child: Text(
                              type[0].toUpperCase() + type.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: recurringType == type
                                      ? AppColors.primary
                                      : AppColors.onSurface),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Alert when approaching limit'),
                  value: notifications,
                  onChanged: (v) => setS(() => notifications = v),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty) {
                      await context.read<ExpenseProvider>().addAllocation(
                            categoryId: categoryId,
                            name: nameCtrl.text.trim(),
                            spendLimit: double.tryParse(limitCtrl.text) ?? 0,
                            isRecurring: isRecurring,
                            recurringType: recurringType,
                            notificationsEnabled: notifications,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Create Allocation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
