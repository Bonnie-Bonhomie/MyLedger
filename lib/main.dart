import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_ledger/Models/allocation_model.dart';
import 'package:my_ledger/Models/category_model.dart';
import 'package:my_ledger/Models/ledger_model.dart';
import 'package:my_ledger/Models/user_model.dart';
import 'package:my_ledger/providers/auth_provider.dart';
import 'package:my_ledger/providers/expense_provider.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:my_ledger/utils/app_theme.dart';
import 'package:my_ledger/utils/constants/app_constant.dart';
import 'package:my_ledger/views/auth/auth_screens.dart';
import 'package:my_ledger/views/auth/face_verify_page.dart';
import 'package:my_ledger/views/auth/verify_email.dart';
import 'package:my_ledger/views/dashboard/dashboard_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // // 1. Resolve device-specific persistent storage path (path_provider)
  // final dir = await getApplicationDocumentsDirectory();

  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AllocationModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(LedgerModelAdapter());

  await Hive.openBox<UserModel>(AppConstants.userBoxName);
  await Hive.openBox<LedgerModel>(AppConstants.ledgerBoxName);
  await Hive.openBox<AllocationModel>(AppConstants.allocationBoxName);
  await Hive.openBox<CategoryModel>(AppConstants.categoryBoxName);


  runApp(const MyLedgerApp());
}




class MyLedgerApp extends StatelessWidget {
  const MyLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const _SplashRouter(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/verify-email': (_) => const VerifyEmailScreen(),
          '/face-verify': (_) => const FaceVerifyScreen(),
          '/dashboard': (_) => const DashboardScreen(),
        },
      ),
    );
  }
}


class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.authState == AuthState.authenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (auth.authState == AuthState.faceVerification) {
      Navigator.pushReplacementNamed(context, '/face-verify');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track every penny with clarity',
              style: TextStyle(color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
