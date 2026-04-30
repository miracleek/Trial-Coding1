import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../services/firestore_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  StreamSubscription? _catSub;
  bool _loading = true;
  String _activeTab = 'Pengeluaran'; // 'Pengeluaran' | 'Pendapatan'

  // Emoji map — same as web app
  static const Map<String, String> _iconMap = {
    'food': '🍽️',
    'car': '🚗',
    'money': '💸',
    'work': '💼',
    'laptop': '💻',
    'chart': '📈',
    'plus': '➕',
    'star': '⭐',
    'home': '🏠',
    'health': '💊',
    'shop': '🛍️',
    'fun': '🎮',
    'edu': '📚',
    'gift': '🎁',
    'pet': '🐾',
    'travel': '✈️',
  };

  @override
  void initState() {
    super.initState();
    _catSub = FirestoreService.categoriesStream().listen((data) {
      if (mounted)
        setState(() {
          _categories = data;
          _loading = false;
        });
    });
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered =>
      _categories.where((c) => c['type'] == _activeTab).toList();

  Color _parseColor(String? hex) {
    try {
      final h = (hex ?? '#6b7280').replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(d.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori dikelola oleh admin',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tab toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Row(children: [_tab('Pengeluaran'), _tab('Pendapatan')]),
          ),
          const SizedBox(height: 24),

          // Category list
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          else if (_filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Belum ada kategori',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            )
          else
            ..._filtered.map((cat) {
              final color = _parseColor(cat['color'] as String?);
              final emoji = _iconMap[cat['icon']] ?? '📌';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSide),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (cat['type'] as String? ?? '').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kategori dikelola oleh admin melalui website. Perubahan akan otomatis tersinkron ke aplikasi ini.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label) {
    final isActive = _activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppTheme.onPrimary : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
