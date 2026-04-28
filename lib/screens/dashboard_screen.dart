import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Pengguna';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $firstName 👋',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berikut ringkasan keuanganmu',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Total Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: const BorderSide(color: AppTheme.primary, width: 4),
                top: const BorderSide(color: AppTheme.borderSide),
                right: const BorderSide(color: AppTheme.borderSide),
                bottom: const BorderSide(color: AppTheme.borderSide),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp 24.500.000',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+4.2% dari bulan lalu',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppTheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income / Expense summary row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  label: 'PEMASUKAN',
                  amount: 'Rp 15.000.000',
                  icon: Icons.arrow_downward,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  label: 'PENGELUARAN',
                  amount: 'Rp 4.250.000',
                  icon: Icons.arrow_upward,
                  color: AppTheme.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribusi Pengeluaran',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'DETAIL',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.primary),
              ),
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
                            Text(
                              '62%',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              'SPENT',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        context,
                        AppTheme.primary,
                        'Kebutuhan',
                        'Rp 1.800.000',
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        context,
                        AppTheme.surfaceHigh,
                        'Gaya Hidup',
                        'Rp 950.000',
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        context,
                        AppTheme.borderSide,
                        'Tabungan',
                        'Rp 370.000',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Icon(Icons.tune, color: AppTheme.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 16),

          TransactionCard(
            title: 'Apple Store Purchase',
            subtitle: 'Tech & Electronics • 2j lalu',
            amount: -999000,
            iconData: Icons.shopping_bag,
          ),
          TransactionCard(
            title: 'Client Payment - UX UI',
            subtitle: 'Freelance • 5j lalu',
            amount: 2450000,
            iconData: Icons.work,
            iconColor: AppTheme.primary,
            iconBgColor: AppTheme.secondaryDark,
          ),
          TransactionCard(
            title: 'The Steakhouse',
            subtitle: 'Makan & Minum • Kemarin',
            amount: -124500,
            iconData: Icons.restaurant,
          ),
          TransactionCard(
            title: 'Transfer Tabungan',
            subtitle: 'Investasi • 22 Agt',
            amount: -500000,
            iconData: Icons.swap_horiz,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSide),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: color, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Color color,
    String label,
    String amount,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(amount, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
