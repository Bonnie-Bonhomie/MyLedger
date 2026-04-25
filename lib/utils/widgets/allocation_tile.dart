
import 'package:flutter/material.dart';
import 'package:my_ledger/Models/allocation_model.dart';
import 'package:my_ledger/providers/expense_provider.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';

class AllocationTile extends StatelessWidget {
  final AllocationModel allocation;
  final String categoryId;

  const AllocationTile({required this.allocation, required this.categoryId,});

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();
    final receipts = expense.receiptsForAllocation(allocation.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(allocation.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (allocation.isRecurring)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent1.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    allocation.recurringType,
                    style:
                    TextStyle(color: AppColors.accent1, fontSize: 10),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context
                    .read<ExpenseProvider>()
                    .deleteAllocation(allocation.id),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.error, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BudgetProgressBar(
              spent: allocation.totalSpent, limit: allocation.spendLimit),
          const SizedBox(height: 8),
          Text(
            '${receipts.length} receipt${receipts.length != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
