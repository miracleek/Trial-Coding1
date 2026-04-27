import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text('Kelola kategori anggaran Anda', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              CustomButton(
                text: 'Tambah',
                fullWidth: false,
                icon: const Icon(Icons.add, size: 16, color: AppTheme.onPrimary),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Toggle "Tab" style
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Pengeluaran',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onPrimary),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Pendapatan',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildCategoryList(),
          
          const SizedBox(height: 32),
          
          // Analysis Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSide),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analisis Anggaran', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(
                        'Lihat bagaimana pengeluaran Anda terbagi per kategori bulan ini.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(text: 'Cek Sekarang', type: ButtonType.ghost, fullWidth: false, onPressed: () {})
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.bar_chart, color: AppTheme.primary, size: 40),
                  ),
                )
              ],
            ),
          )
          
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        _categoryItem(Icons.shopping_cart, 'Belanja', Colors.orange),
        _categoryItem(Icons.restaurant, 'Makan', Colors.blue),
        _categoryItem(Icons.medication, 'Obat', Colors.red),
        _categoryItem(Icons.directions_car, 'Transportasi', Colors.purple),
        _categoryItem(Icons.movie, 'Hiburan', Colors.green),
        _categoryItem(Icons.school, 'Pendidikan', Colors.teal),
      ],
    );
  }

  Widget _categoryItem(IconData icon, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSide),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textMain)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.surfaceHigh, borderRadius: BorderRadius.circular(4)),
                  child: const Text('PENGELUARAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
                )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }
}
