import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background "Businessman" gradient placeholder
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E282E), Color(0xFF121414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: AppTheme.onPrimary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FinTrack',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Kelola Keuangan',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  Text(
                    'Lebih Cerdas.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureRow(context, 'Lacak setiap pengeluaran otomatis'),
                  const SizedBox(height: 16),
                  _buildFeatureRow(context, 'Analisis cerdas AI untuk tabungan'),
                  const SizedBox(height: 16),
                  _buildFeatureRow(context, 'Keamanan data enkripsi perbankan'),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderSide),
                    ),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Masuk dengan Google',
                          // Custom Icon since Lucide doesn't have standard Brand icons usually
                          icon: const Icon(Icons.g_mobiledata, size: 24), 
                          onPressed: () => context.go('/dashboard'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.borderSide)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Atau gunakan email', style: Theme.of(context).textTheme.labelSmall),
                            ),
                            const Expanded(child: Divider(color: AppTheme.borderSide)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Daftar Gratis',
                          type: ButtonType.ghost,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 24),
                        Text.rich(
                          TextSpan(
                            text: 'Dengan melanjutkan, Anda menyetujui\n',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.5),
                            children: [
                              TextSpan(text: 'Ketentuan Layanan', style: TextStyle(color: AppTheme.primary, decoration: TextDecoration.underline)),
                              const TextSpan(text: ' & '),
                              TextSpan(text: 'Privasi', style: TextStyle(color: AppTheme.primary, decoration: TextDecoration.underline)),
                              const TextSpan(text: ' kami.'),
                            ]
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
      ],
    );
  }
}
