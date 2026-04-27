import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text('Rp 45.250.000', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 24)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 4),
                    Text('+12.5% this month', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Add Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tambah Pendapatan', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                    const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 24),
                  ],
                ),
                const SizedBox(height: 24),
                const CustomTextField(label: 'Item Name', hintText: 'e.g. Monthly Salary'),
                const SizedBox(height: 16),
                const CustomTextField(label: 'Amount (RP)', hintText: '0', prefixIcon: Padding(padding: EdgeInsets.all(12.0), child: Text('Rp', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textMain)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceHigh,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSide)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                            ],
                            onChanged: (val) {},
                            value: 'Salary',
                            icon: const Icon(Icons.expand_more, size: 16),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Date', 
                        hintText: 'mm/dd/yyyy',
                        suffixIcon: const Icon(Icons.calendar_today, size: 16),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(text: 'Simpan Pendapatan', onPressed: () {})
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Income', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text('SEE ALL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          
          TransactionCard(title: 'Gaji Bulanan', subtitle: 'Salary • 24 Oct 2023', amount: 15000000, iconData: Icons.payments, iconColor: AppTheme.primary, iconBgColor: AppTheme.secondaryDark),
          TransactionCard(title: 'Project UI Design', subtitle: 'Freelance • 22 Oct 2023', amount: 4500000, iconData: Icons.laptop_mac, iconColor: AppTheme.primary, iconBgColor: AppTheme.secondaryDark),
          TransactionCard(title: 'Dividen Saham', subtitle: 'Investment • 20 Oct 2023', amount: 750000, iconData: Icons.trending_up, iconColor: AppTheme.primary, iconBgColor: AppTheme.secondaryDark),
        ],
      ),
    );
  }
}
