import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData iconData;
  final Color? iconColor;
  final Color? iconBgColor;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.iconData,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);
    final isPositive = amount >= 0;
    final amountColor = isPositive ? AppTheme.primary : AppTheme.textMain;
    final prefix = isPositive ? '+' : '-';
    final absAmount = amount.abs();
    final formatted =
        '${prefix}Rp ${absAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    final accentColor = isPositive
        ? const Color(0xFF00BFA5)
        : const Color(0xFFFF8A65);

    return Container(
      margin: EdgeInsets.only(bottom: d.itemSpacing),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(d.radiusLG),
        border: Border.all(color: AppTheme.borderSide),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 72 * (d.screenW / 360).clamp(0.85, 1.3),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(d.radiusLG),
                bottomLeft: Radius.circular(d.radiusLG),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: d.cardPadding,
                vertical: d.cardPadding,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44 * (d.screenW / 360).clamp(0.85, 1.2),
                    height: 44 * (d.screenW / 360).clamp(0.85, 1.2),
                    decoration: BoxDecoration(
                      color: iconBgColor ?? AppTheme.surfaceHigh,
                      borderRadius: BorderRadius.circular(d.radiusMD),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor ?? AppTheme.textMain,
                      size: d.iconMD,
                    ),
                  ),
                  SizedBox(width: d.itemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: d.fontMD,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: d.fontSM,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatted,
                        style: TextStyle(
                          fontSize: d.fontSM,
                          color: amountColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        isPositive ? 'CREDIT' : 'DEBIT',
                        style: TextStyle(
                          fontSize: d.fontXS,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
