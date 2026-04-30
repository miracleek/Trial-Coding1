import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';
import '../services/firestore_service.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _categories = [];
  StreamSubscription? _txSub;
  StreamSubscription? _catSub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _txSub = FirestoreService.transactionsStream(uid).listen((data) {
        if (mounted) {
          setState(() {
            _transactions = data
                .where((t) => t['type'] == 'Pendapatan')
                .toList();
            _loading = false;
          });
        }
      });
    }
    _catSub = FirestoreService.categoriesStream().listen((data) {
      if (mounted) {
        setState(() {
          _categories = data.where((c) => c['type'] == 'Pendapatan').toList();
          if (_selectedCategory == null && _categories.isNotEmpty) {
            _selectedCategory = _categories.first['name'];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _txSub?.cancel();
    _catSub?.cancel();
    super.dispose();
  }

  double get _totalIncome =>
      _transactions.fold(0, (s, t) => s + (t['amount'] as num).toDouble());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: AppTheme.onPrimary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final amount = double.tryParse(amountText);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (name.isEmpty || amount == null || amount <= 0 || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama dan jumlah dengan benar'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirestoreService.addTransaction(
        uid: uid,
        name: name,
        amount: amount,
        category: _selectedCategory ?? 'Lainnya',
        date: FirestoreService.formatDate(_selectedDate),
        type: 'Pendapatan',
      );
      _nameController.clear();
      _amountController.clear();
      setState(() => _selectedDate = DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendapatan berhasil disimpan'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirestoreService.deleteTransaction(uid, id);
  }

  String _formatRp(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(d.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Card
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.borderSide),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: AppTheme.primary),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL PEMASUKAN',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatRp(_totalIncome),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
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
                                  '${_transactions.length} transaksi',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form
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
                    Text(
                      'Tambah Pendapatan',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Nama Item',
                  hintText: 'cth. Gaji Bulanan',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                // Jumlah + Tanggal side by side
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Jumlah (Rp)',
                        hintText: '0',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
                // Kategori full width
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
                    _categories.isEmpty
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
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
                                  (c) => DropdownMenuItem(
                                    value: c['name'] as String,
                                    child: Text(c['name']),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v),
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
                  text: _saving ? 'Menyimpan...' : 'Simpan Pendapatan',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Pendapatan',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_transactions.length} data',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          else if (_transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Belum ada pendapatan',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            )
          else
            ..._transactions.map(
              (t) => Dismissible(
                key: Key(t['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: AppTheme.danger),
                ),
                onDismissed: (_) => _delete(t['id']),
                child: TransactionCard(
                  title: t['name'] ?? '',
                  subtitle: '${t['category'] ?? ''} • ${t['date'] ?? ''}',
                  amount: (t['amount'] as num).toDouble(),
                  iconData: Icons.payments,
                  iconColor: AppTheme.primary,
                  iconBgColor: AppTheme.secondaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
