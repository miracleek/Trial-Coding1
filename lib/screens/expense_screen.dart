import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Makan & Minum';
  DateTime _selectedDate = DateTime.now();

  // Local list — akan diganti Firestore di step berikutnya
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Dinner at Senopati',
      'subtitle': 'Makan & Minum • 24 Okt 2024',
      'amount': -320000.0,
      'icon': Icons.restaurant,
    },
    {
      'title': 'Uber Ride',
      'subtitle': 'Transportasi • 23 Okt 2024',
      'amount': -45000.0,
      'icon': Icons.directions_car,
    },
    {
      'title': 'Netflix Premium',
      'subtitle': 'Hiburan • 20 Okt 2024',
      'amount': -186000.0,
      'icon': Icons.play_circle_filled,
    },
  ];

  double get _totalExpense =>
      _transactions.fold(0, (sum, t) => sum + (t['amount'] as double).abs());

  final List<String> _categories = [
    'Makan & Minum',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.danger,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveExpense() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama dan jumlah dengan benar'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final dateStr =
        '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';

    setState(() {
      _transactions.insert(0, {
        'title': name,
        'subtitle': '$_selectedCategory • $dateStr',
        'amount': -amount, // negatif untuk pengeluaran
        'icon': _iconForCategory(_selectedCategory),
      });
      _nameController.clear();
      _amountController.clear();
      _selectedDate = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengeluaran berhasil disimpan'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Makan & Minum':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Hiburan':
        return Icons.play_circle_filled;
      case 'Kesehatan':
        return Icons.medication;
      case 'Pendidikan':
        return Icons.school;
      default:
        return Icons.receipt;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _formatRupiah(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Expense Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: const BorderSide(color: AppTheme.danger, width: 4),
                top: const BorderSide(color: AppTheme.borderSide),
                right: const BorderSide(color: AppTheme.borderSide),
                bottom: const BorderSide(color: AppTheme.borderSide),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PENGELUARAN',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRupiah(_totalExpense),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_down,
                      color: AppTheme.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_transactions.length} transaksi',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppTheme.danger),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Tambah Pengeluaran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
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
                CustomTextField(
                  label: 'Nama Item',
                  hintText: 'cth. Starbucks Coffee',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Jumlah (Rp)',
                        hintText: '50.000',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Date picker
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceHigh,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderSide),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        color: AppTheme.textMain,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.borderSide,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.borderSide,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      dropdownColor: AppTheme.surfaceHigh,
                      style: const TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 14,
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                      icon: const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Simpan Pengeluaran',
                  type: ButtonType.danger,
                  onPressed: _saveExpense,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Pengeluaran',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'LIHAT SEMUA',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.danger),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ..._transactions.map(
            (t) => TransactionCard(
              title: t['title'],
              subtitle: t['subtitle'],
              amount: t['amount'],
              iconData: t['icon'],
            ),
          ),
        ],
      ),
    );
  }
}
