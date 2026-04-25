import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static final List<Color> _chartColors = [
    AppColors.primary,
    AppColors.accent1,
    AppColors.accent2,
    AppColors.success,
    AppColors.warning,
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();
    final spendData = expense.spendByCategory.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        automaticallyImplyLeading: false,
      ),
      body: expense.receipts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insights_outlined,
                      color: AppColors.onSurfaceMuted, size: 64),
                  const SizedBox(height: 16),
                  Text('No data yet',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Add expenses to see insights',
                      style: TextStyle(color: AppColors.onSurfaceMuted)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─ Smart Allocation Detection ─
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent2.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.accent2),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Smart Allocation Detection',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                _getSmartInsight(expense),
                                style: TextStyle(
                                    color: AppColors.onSurfaceMuted,
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─ Total overview ─
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Spent',
                          value: formatCurrency(expense.totalSpent),
                          valueColor: AppColors.error,
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Budget Left',
                          value: formatCurrency(
                            (expense.totalBudget - expense.totalSpent)
                                .clamp(0, double.infinity),
                          ),
                          valueColor: AppColors.success,
                          icon: Icons.savings_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─ Pie chart ─
                  if (spendData.isNotEmpty) ...[
                    Text('Spend by Category',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 50,
                                sections: spendData.asMap().entries.map((e) {
                                  final color = _chartColors[
                                      e.key % _chartColors.length];
                                  final pct =
                                      expense.totalSpent > 0
                                          ? (e.value.value /
                                                  expense.totalSpent *
                                                  100)
                                              .toStringAsFixed(1)
                                          : '0';
                                  return PieChartSectionData(
                                    value: e.value.value,
                                    color: color,
                                    title: '$pct%',
                                    titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                    radius: 70,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: spendData.asMap().entries.map((e) {
                              final color =
                                  _chartColors[e.key % _chartColors.length];
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${e.value.key}: ${formatCurrency(e.value.value)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─ Top Allocations ─
                  Text('Top Allocations by Spend',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...expense.allocations
                      .where((a) => a.totalSpent > 0)
                      .toList()
                      .take(5)
                      .map((a) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(a.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      formatCurrency(a.totalSpent),
                                      style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                BudgetProgressBar(
                                    spent: a.totalSpent, limit: a.spendLimit),
                              ],
                            ),
                          )),
                ],
              ),
            ),
    );
  }

  String _getSmartInsight(ExpenseProvider expense) {
    if (expense.receipts.isEmpty) {
      return 'No spending data yet. Add some expenses to get insights.';
    }
    final overBudget = expense.allocations
        .where((a) => a.spendLimit > 0 && a.totalSpent > a.spendLimit)
        .toList();
    if (overBudget.isNotEmpty) {
      return '⚠️ ${overBudget.first.name} has exceeded its budget limit. Consider reviewing your allocations.';
    }
    final nearLimit = expense.allocations.where((a) =>
        a.spendLimit > 0 && a.totalSpent / a.spendLimit > 0.8).toList();
    if (nearLimit.isNotEmpty) {
      return '${nearLimit.first.name} is at ${(nearLimit.first.totalSpent / nearLimit.first.spendLimit * 100).toStringAsFixed(0)}% of its budget. Keep an eye on it.';
    }
    return 'Your spending is within budget. Great job tracking your expenses! 🎉';
  }
}
