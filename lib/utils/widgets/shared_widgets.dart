import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_ledger/Models/ledger_model.dart';
import 'package:my_ledger/utils/app_color.dart';



// ─── Currency formatter ──────────────────────────────────────────────────────
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

// ─── Stat card ───────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 10),
          ],
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurfaceMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}


class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double limit;

  const BudgetProgressBar({super.key, required this.spent, required this.limit});

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.85
        ? AppColors.error
        : ratio > 0.6
            ? AppColors.warning
            : AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatCurrency(spent),
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
            ),
            Text(
              '/ ${formatCurrency(limit)}',
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
            ),
          ],
        ),
      ],
    );
  }
}



class PrimaryFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  const PrimaryFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
