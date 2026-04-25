import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ledger/providers/auth_provider.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Verify your email',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${auth.currentUser?.email ?? 'your email'}. Enter it below.',
                style: TextStyle(color: AppColors.onSurfaceMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: '------',
                  counterText: '',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 8),
              Text('(Hint: use 123456 for demo)',
                  style:
                  TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  final ok = await auth.verifyEmail(_codeCtrl.text);
                  setState(() => _loading = false);
                  if (ok && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/face-verify');
                  } else {
                    setState(() => _error = 'Invalid code. Try 123456.');
                  }
                },
                child: _loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Verify Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}