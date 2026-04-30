import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

class CustomBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: d.pagePadding,
        vertical: d.itemSpacing,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.borderSide)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(context, d, 0, 'DASHBOARD', Icons.grid_view),
            _item(context, d, 1, 'INCOME', Icons.account_balance_wallet),
            _item(context, d, 2, 'EXPENSE', Icons.receipt),
            _item(context, d, 3, 'CATEGORIES', Icons.category),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    AppDimensions d,
    int index,
    String label,
    IconData icon,
  ) {
    final isActive = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: d.cardPadding,
          vertical: d.itemSpacing * 0.6,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(d.radiusMD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.onPrimary : AppTheme.textMuted,
              size: d.iconMD,
            ),
            SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: d.fontXS,
                color: isActive ? AppTheme.onPrimary : AppTheme.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
