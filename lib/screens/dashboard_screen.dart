import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../widgets/transaction_card.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _categories = [];
  StreamSubscription? _txSub;
  StreamSubscription? _catSub;
  bool _loading = true;
  int _chartTab = 0; // 0 = Pengeluaran, 1 = Pemasukan

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _txSub = FirestoreService.transactionsStream(uid).listen((data) {
        if (mounted)
          setState(() {
            _transactions = data;
            _loading = false;
          });
      });
      _catSub = FirestoreService.categoriesStream().listen((data) {
        if (mounted) setState(() => _categories = data);
      });
    }
  }

  @override
  void dispose() {
    _txSub?.cancel();
    _catSub?.cancel();
    super.dispose();
  }

  double get _totalIncome => _transactions
      .where((t) => t['type'] == 'Pendapatan')
      .fold(0.0, (s, t) => s + (t['amount'] as num).toDouble());

  double get _totalExpense => _transactions
      .where((t) => t['type'] == 'Pengeluaran')
      .fold(0.0, (s, t) => s + (t['amount'] as num).toDouble());

  double get _balance => _totalIncome - _totalExpense;

  // Top 3 expense categories
  List<Map<String, dynamic>> get _expenseByCat {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t['type'] == 'Pengeluaran')) {
      final cat = t['category'] as String? ?? 'Lainnya';
      map[cat] = (map[cat] ?? 0) + (t['amount'] as num).toDouble();
    }
    return (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => {'name': e.key, 'amount': e.value})
        .toList();
  }

  // Top 3 income categories
  List<Map<String, dynamic>> get _incomeByCat {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t['type'] == 'Pendapatan')) {
      final cat = t['category'] as String? ?? 'Lainnya';
      map[cat] = (map[cat] ?? 0) + (t['amount'] as num).toDouble();
    }
    return (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(4)
        .map((e) => {'name': e.key, 'amount': e.value})
        .toList();
  }

  String _fmt(double v) {
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

  Color _catColor(String name) {
    final cat = _categories.firstWhere(
      (c) => c['name'] == name,
      orElse: () => {'color': '#6b7280'},
    );
    final hex = (cat['color'] as String? ?? '#6b7280').replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Pengguna';
    final recent = _transactions.take(5).toList();
    final expCats = _expenseByCat;
    final incCats = _incomeByCat;
    final spentPct = _totalIncome > 0
        ? (_totalExpense / _totalIncome * 100).clamp(0.0, 100.0)
        : 0.0;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(d.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ 1. Greeting â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
              ),
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: d.cardAvatarRadius,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
            ],
          ),
          SizedBox(height: d.itemSpacing),

          // â”€â”€ 2. Balance Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ClipRRect(
            borderRadius: BorderRadius.circular(d.radiusLG),
            child: Container(
              width: double.infinity,
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
                        padding: EdgeInsets.all(d.cardPadding + 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL BALANCE',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(height: 6),
                            Text(
                              _fmt(_balance),
                              style: TextStyle(
                                fontSize: d.font2XL,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMain,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _balance >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: _balance >= 0
                                      ? AppTheme.primary
                                      : AppTheme.danger,
                                  size: d.iconSM,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${_transactions.length} transaksi total',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: _balance >= 0
                                            ? AppTheme.primary
                                            : AppTheme.danger,
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
              ),
            ),
          ),
          SizedBox(height: d.itemSpacing),

          // â”€â”€ 3. Chart Card (Pengeluaran + Pemasukan tabs) â”€â”€
          Container(
            padding: EdgeInsets.all(d.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(d.radiusLG),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab header
                Row(
                  children: [
                    _chartTabBtn(d, 0, 'Pengeluaran'),
                    SizedBox(width: d.itemSpacing * 0.5),
                    _chartTabBtn(d, 1, 'Pemasukan'),
                  ],
                ),
                SizedBox(height: d.itemSpacing),

                // Tab content
                _chartTab == 0
                    ? _expenseChart(context, d, expCats, spentPct)
                    : _incomeChart(context, d, incCats),
              ],
            ),
          ),
          SizedBox(height: d.itemSpacing),

          // â”€â”€ 4. Summary row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  context,
                  d,
                  label: 'PEMASUKAN',
                  amount: _fmt(_totalIncome),
                  icon: Icons.arrow_downward,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(width: d.itemSpacing),
              Expanded(
                child: _summaryCard(
                  context,
                  d,
                  label: 'PENGELUARAN',
                  amount: _fmt(_totalExpense),
                  icon: Icons.arrow_upward,
                  color: AppTheme.danger,
                ),
              ),
            ],
          ),
          SizedBox(height: d.sectionSpacing),

          // â”€â”€ 5. Recent transactions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: d.fontXL,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain,
                ),
              ),
              Icon(Icons.tune, color: AppTheme.textMuted, size: d.iconMD),
            ],
          ),
          SizedBox(height: d.itemSpacing),

          if (recent.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(d.sectionSpacing),
                child: Text(
                  'Belum ada transaksi',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            )
          else
            ...recent.map((t) {
              final isIncome = t['type'] == 'Pendapatan';
              final amount = (t['amount'] as num).toDouble();
              return TransactionCard(
                title: t['name'] ?? '',
                subtitle: '${t['category'] ?? ''} • ${t['date'] ?? ''}',
                amount: isIncome ? amount : -amount,
                iconData: isIncome ? Icons.payments : Icons.receipt,
                iconColor: isIncome ? AppTheme.primary : null,
                iconBgColor: isIncome ? AppTheme.secondaryDark : null,
              );
            }),
        ],
      ),
    );
  }

  // â”€â”€ Chart tab button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _chartTabBtn(AppDimensions d, int idx, String label) {
    final active = _chartTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _chartTab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: d.cardPadding,
          vertical: d.itemSpacing * 0.5,
        ),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(d.radiusSM),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: d.fontSM,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.onPrimary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  // â”€â”€ Expense pie chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _expenseChart(
    BuildContext context,
    AppDimensions d,
    List<Map<String, dynamic>> cats,
    double spentPct,
  ) {
    if (cats.isEmpty) {
      return SizedBox(
        height: d.chartSize,
        child: Center(
          child: Text(
            'Belum ada pengeluaran',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: d.chartSize,
          height: d.chartSize,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: d.chartCenterRadius,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {},
                    enabled: true,
                  ),
                  sections: cats
                      .map(
                        (e) => PieChartSectionData(
                          color: _catColor(e['name']),
                          value: e['amount'],
                          title: '',
                          radius: d.chartRingRadius,
                          badgeWidget: null,
                        ),
                      )
                      .toList(),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${spentPct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: d.fontMD,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMain,
                      ),
                    ),
                    Text(
                      'SPENT',
                      style: TextStyle(
                        fontSize: d.fontXS,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: d.itemSpacing),
        Expanded(
          child: Column(
            children: cats.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: d.itemSpacing * 0.6),
                child: _legendItem(
                  context,
                  d,
                  _catColor(e['name']),
                  e['name'],
                  _fmt(e['amount']),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Income pie chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _incomeChart(
    BuildContext context,
    AppDimensions d,
    List<Map<String, dynamic>> cats,
  ) {
    if (cats.isEmpty) {
      return SizedBox(
        height: d.chartSize,
        child: Center(
          child: Text(
            'Belum ada pemasukan',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }

    final totalIncome = cats.fold(0.0, (s, e) => s + (e['amount'] as double));
    // Persentase kategori terbesar terhadap total semua pemasukan
    final topPct = _totalIncome > 0
        ? ((cats.first['amount'] as double) / _totalIncome * 100).clamp(
            0.0,
            100.0,
          )
        : 0.0;

    return Row(
      children: [
        SizedBox(
          width: d.chartSize,
          height: d.chartSize,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: d.chartCenterRadius,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {},
                    enabled: true,
                  ),
                  sections: cats
                      .map(
                        (e) => PieChartSectionData(
                          color: _catColor(e['name']),
                          value: e['amount'],
                          title: '',
                          radius: d.chartRingRadius,
                        ),
                      )
                      .toList(),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${topPct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: d.fontMD,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMain,
                      ),
                    ),
                    Text(
                      cats.first['name'],
                      style: TextStyle(
                        fontSize: d.fontXS,
                        color: AppTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: d.itemSpacing),
        Expanded(
          child: Column(
            children: cats.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: d.itemSpacing * 0.6),
                child: _legendItem(
                  context,
                  d,
                  _catColor(e['name']),
                  e['name'],
                  _fmt(e['amount']),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Summary card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _summaryCard(
    BuildContext context,
    AppDimensions d, {
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(d.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(d.radiusLG),
        border: Border.all(color: AppTheme.borderSide),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(d.itemSpacing * 0.6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(d.radiusSM),
            ),
            child: Icon(icon, color: color, size: d.iconSM),
          ),
          SizedBox(width: d.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                SizedBox(height: 3),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: d.fontSM,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Legend item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _legendItem(
    BuildContext context,
    AppDimensions d,
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
        SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: d.fontSM,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: d.fontSM, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
