import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

enum ButtonType { primary, secondary, danger, ghost }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);

    Color bgColor;
    Color textColor;
    BorderSide? border;

    switch (type) {
      case ButtonType.primary:
        bgColor = AppTheme.primary;
        textColor = AppTheme.onPrimary;
        break;
      case ButtonType.danger:
        bgColor = AppTheme.danger;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        bgColor = AppTheme.secondaryDark;
        textColor = AppTheme.primary;
        break;
      case ButtonType.ghost:
        bgColor = Colors.transparent;
        textColor = AppTheme.textMain;
        border = const BorderSide(color: AppTheme.borderSide);
        break;
    }

    return SizedBox(
      height: d.buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(d.radiusSM),
            side: border ?? BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: d.cardPadding),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: 8)],
            Text(
              text,
              style: TextStyle(
                fontSize: d.fontMD,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
