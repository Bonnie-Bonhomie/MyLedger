import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/ledger_tile.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';


class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();
    final receipts = expense.receipts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${receipts.length} transactions',
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
      body: receipts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: AppColors.onSurfaceMuted, size: 64),
                  const SizedBox(height: 16),
                  Text('No transactions yet',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Add your first expense from the home screen',
                      style: TextStyle(color: AppColors.onSurfaceMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receipts.length,
              itemBuilder: (_, i) {
                final r = receipts[i];
                final cat = expense.categoryById(r.categoryId);
                final alloc = expense.allocationById(r.allocationId);
                return LedgerTile(
                  receipt: r,
                  categoryName: cat?.name,
                  allocationName: alloc?.name,
                  onDelete: () => _confirmDelete(context, expense, r),
                );
              },
            ),
    );
  }

  void _confirmDelete(context, ExpenseProvider expense, receipt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to delete this transaction? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await expense.deleteReceipt(receipt);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
