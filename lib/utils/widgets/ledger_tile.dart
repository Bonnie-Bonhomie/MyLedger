
// ─── Receipt tile ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_ledger/Models/ledger_model.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/shared_widgets.dart';

class LedgerTile extends StatelessWidget {
  final LedgerModel receipt;
  final String? categoryName;
  final String? allocationName;
  final VoidCallback? onDelete;

  const LedgerTile({
    super.key,
    required this.receipt,
    this.categoryName,
    this.allocationName,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.description,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (categoryName != null) categoryName!,
                    if (allocationName != null) allocationName!,
                    DateFormat('MMM d, yyyy').format(receipt.date),
                  ].join(' • '),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(receipt.amount),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.error.withOpacity(0.7)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
