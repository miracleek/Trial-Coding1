import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary Overview', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          
          // Total Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: const BorderSide(color: AppTheme.primary, width: 4), top: const BorderSide(color: AppTheme.borderSide), right: const BorderSide(color: AppTheme.borderSide), bottom: const BorderSide(color: AppTheme.borderSide)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL BALANCE', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                Text('\$24,500.00', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 4),
                    Text('+4.2% from last month', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expense Distribution', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
              Text('SEE DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Chart Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: AppTheme.primary,
                              value: 62,
                              title: '',
                              radius: 12,
                            ),
                            PieChartSectionData(
                              color: AppTheme.surfaceHigh,
                              value: 38,
                              title: '',
                              radius: 12,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('62%', style: Theme.of(context).textTheme.labelLarge),
                            Text('SPENT', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(context, AppTheme.primary, 'Essential', '\$1,800'),
                      const SizedBox(height: 12),
                      _buildLegendItem(context, AppTheme.surfaceHigh, 'Lifestyle', '\$950'),
                      const SizedBox(height: 12),
                      _buildLegendItem(context, AppTheme.borderSide, 'Savings', '\$370'),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaksi Terbaru', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
              const Icon(Icons.tune, color: AppTheme.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          
          TransactionCard(title: 'Apple Store Purchase', subtitle: 'Tech & Electronics • 2h ago', amount: -999.00, iconData: Icons.shopping_bag),
          TransactionCard(title: 'Client Payment - UX UI', subtitle: 'Freelance Income • 5h ago', amount: 2450.00, iconData: Icons.work, iconColor: AppTheme.primary, iconBgColor: AppTheme.secondaryDark),
          TransactionCard(title: 'The Steakhouse', subtitle: 'Food & Dining • Yesterday', amount: -124.50, iconData: Icons.restaurant),
          TransactionCard(title: 'Savings Transfer', subtitle: 'Investment • Aug 22', amount: -500.00, iconData: Icons.swap_horiz),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, String amount) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(amount, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
