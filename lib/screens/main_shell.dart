import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../services/auth_service.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  void _showProfileSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final d = AppDimensions.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(d.radiusXL)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          d.sectionSpacing,
          d.itemSpacing,
          d.sectionSpacing,
          d.sectionSpacing + d.safeBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderSide,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: d.sectionSpacing),

            // Avatar
            CircleAvatar(
              radius: d.cardAvatarRadius * 2,
              backgroundColor: AppTheme.surfaceHigh,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: d.cardAvatarRadius * 2,
                      color: AppTheme.textMuted,
                    )
                  : null,
            ),
            SizedBox(height: d.itemSpacing),

            Text(
              user?.displayName ?? 'Pengguna',
              style: TextStyle(
                fontSize: d.fontXL,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
            SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(fontSize: d.fontMD, color: AppTheme.textMuted),
            ),
            SizedBox(height: d.sectionSpacing),
            const Divider(color: AppTheme.borderSide),
            SizedBox(height: d.itemSpacing),

            SizedBox(
              width: double.infinity,
              height: d.buttonHeight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger.withValues(alpha: 0.15),
                  foregroundColor: AppTheme.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(d.radiusMD),
                    side: const BorderSide(color: AppTheme.danger),
                  ),
                ),
                icon: Icon(Icons.logout, size: d.iconMD),
                label: Text(
                  'Keluar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: d.fontLG,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await AuthService.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final d = AppDimensions.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _showProfileSheet(context),
              child: CircleAvatar(
                backgroundColor: AppTheme.surfaceHigh,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                radius: d.avatarRadius,
                child: user?.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: d.avatarRadius,
                        color: AppTheme.textMuted,
                      )
                    : null,
              ),
            ),
            SizedBox(width: d.itemSpacing),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/app_icon.png', width: 24, height: 24, fit: BoxFit.cover),
            ),
            SizedBox(width: 6),
            Text(
              'Monity',
              style: TextStyle(
                fontSize: d.fontLG,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
          ],
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: CustomBottomNavBar(navigationShell: navigationShell),
    );
  }
}
