import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

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
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL BALANCE', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                Text('Rp 4.250.000', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 24)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trending_down, color: AppTheme.danger, size: 16),
                    const SizedBox(width: 4),
                    Text('-Rp 840.000 this month', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.danger)),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text('Tambah Pengeluaran', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 16),
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
                const CustomTextField(label: 'Item Name', hintText: 'e.g. Starbucks Coffee'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(label: 'Amount (RP)', hintText: '50.000')
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Date', 
                        hintText: '10/27/2023',
                        suffixIcon: const Icon(Icons.calendar_today, size: 16),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
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
                        DropdownMenuItem(value: 'Food & Drinks', child: Text('Food & Drinks')),
                      ],
                      onChanged: (val) {},
                      value: 'Food & Drinks',
                      icon: const Icon(Icons.expand_more, size: 16),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(text: 'Submit Expense', type: ButtonType.danger, onPressed: () {})
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Expense', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text('SEE ALL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.danger)),
            ],
          ),
          const SizedBox(height: 16),
          
          TransactionCard(title: 'Dinner at Senopati', subtitle: 'Food & Drinks • 24 Oct 2023', amount: -320000, iconData: Icons.restaurant),
          TransactionCard(title: 'Uber Ride', subtitle: 'Transportation • 23 Oct 2023', amount: -45000, iconData: Icons.directions_car),
          TransactionCard(title: 'Netflix Premium', subtitle: 'Entertainment • 20 Oct 2023', amount: -186000, iconData: Icons.play_circle_filled),
        ],
      ),
    );
  }
}
