import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ledger/utils/app_color.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─ Profile header ─
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User',
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          style: TextStyle(
                              color: AppColors.onSurfaceMuted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StatusBadge(
                            label: user?.isEmailVerified == true
                                ? 'Email Verified'
                                : 'Email Unverified',
                            isGood: user?.isEmailVerified == true,
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(
                            label: user?.isFaceVerified == true
                                ? 'ID Verified'
                                : 'ID Unverified',
                            isGood: user?.isFaceVerified == true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('Account'),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordSheet(context),
          ),
          _SettingsTile(
            icon: Icons.face_retouching_natural_rounded,
            title: 'ID Verification (Facial)',
            subtitle: 'Re-verify your identity',
            onTap: () => Navigator.pushNamed(context, '/face-verify'),
          ),

          const SizedBox(height: 16),
          _SectionLabel('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),

          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.cardBg,
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await auth.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool loading = false;
    String? message;

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
              Text('Change Password',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
              ),
              if (message != null) ...[
                const SizedBox(height: 10),
                Text(message!,
                    style: TextStyle(
                        color: message!.contains('success')
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 13)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setS(() => loading = true);
                        final ok = await ctx.read<AuthProvider>().changePassword(
                              current: currentCtrl.text,
                              newPass: newCtrl.text,
                              confirm: confirmCtrl.text,
                            );
                        setS(() {
                          loading = false;
                          message = ok
                              ? 'Password changed successfully!'
                              : ctx.read<AuthProvider>().error;
                        });
                        if (ok) {
                          await Future.delayed(const Duration(seconds: 1));
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.onSurfaceMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isGood;

  const _StatusBadge({required this.label, required this.isGood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isGood ? AppColors.success : AppColors.error).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: isGood ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
