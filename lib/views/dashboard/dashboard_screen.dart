import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ledger/providers/auth_provider.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/widgets/ledger_tile.dart';
import 'package:my_ledger/utils/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../budget/budget_screen.dart';
import '../ledger/ledger_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    LedgerScreen(),
    BudgetScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? PrimaryFAB(
              onPressed: _showQuickAddDialog,
              icon: Icons.add_rounded,
              label: 'Add Expense',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppColors.surfaceVariant,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primary),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog() {
    final expense = context.read<ExpenseProvider>();
    if (expense.allocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a budget allocation first!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _QuickAddSheet(),
    );
  }
}


class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final expense = context.watch<ExpenseProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${auth.currentUser?.name.split(' ').first ?? 'User'}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                Text("Here's your spending summary",
                    style: TextStyle(
                        fontSize: 13, color: AppColors.onSurfaceMuted)),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─ Spending overview card ─
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Spent',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(expense.totalSpent),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _MiniStat(
                            label: 'Budget',
                            value: formatCurrency(expense.totalBudget),
                          ),
                          const SizedBox(width: 24),
                          _MiniStat(
                            label: 'Remaining',
                            value: formatCurrency(
                                (expense.totalBudget - expense.totalSpent)
                                    .clamp(0, double.infinity)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─ Quick stats ─
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Categories',
                        value: '${expense.categories.length}',
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Allocations',
                        value: '${expense.allocations.length}',
                        icon: Icons.folder_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Ledgers',
                        value: '${expense.receipts.length}',
                        icon: Icons.receipt_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─ Recent transactions ─
                SectionHeader(
                  title: 'Recent Transactions',
                  action: 'See all',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                if (expense.recentReceipts.isEmpty)
                  _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No transactions yet.\nTap to add one.',
                  )
                else
                  ...expense.recentReceipts.map((r) {
                    final cat = expense.categoryById(r.categoryId);
                    final alloc = expense.allocationById(r.allocationId);
                    return LedgerTile(
                      receipt: r,
                      categoryName: cat?.name,
                      allocationName: alloc?.name,
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: AppColors.onSurfaceMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.onSurfaceMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}


class _QuickAddSheet extends StatefulWidget {
  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedAllocationId;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Add Expense',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAllocationId,
              decoration: const InputDecoration(
                labelText: 'Allocation',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              dropdownColor: AppColors.cardBg,
              items: expense.allocations
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAllocationId = v),
              validator: (v) => v == null ? 'Select allocation' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (₦)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final alloc = expense.allocationById(_selectedAllocationId!);
                await expense.addReceipt(
                  allocationId: _selectedAllocationId!,
                  categoryId: alloc!.categoryId,
                  description: _descCtrl.text.trim(),
                  amount: double.parse(_amountCtrl.text),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
