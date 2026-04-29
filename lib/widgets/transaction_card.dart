import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final isPositive = amount >= 0;
    
    // In design, positive matches Electric Lime, negative uses white text.
    final amountColor = isPositive ? AppTheme.primary : AppTheme.textMain;
    final prefix = isPositive ? '+' : '-';
    // Format amount (very basic formatting, assumes amount is absolute value if negative passed but here we just check)
    final absAmount = amount.abs();
    final formattedAmount = '${prefix}Rp ${absAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    // Highlight border for visually distinguishing if necessary, like the design.
    final leftBorderColor = isPositive ? const Color(0xFF00BFA5) : const Color(0xFFFF8A65); // Some soft hint colors from design screenshots

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSide),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: leftBorderColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: iconColor ?? AppTheme.textMain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPositive ? 'CREDIT' : 'DEBIT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
