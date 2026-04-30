import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (result == null && mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppDimensions.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────
          Image.asset('assets/background.jpeg', fit: BoxFit.cover),

          // ── Dark overlay ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000), // 60% black top
                  Color(0xDD121414), // 87% dark bottom
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: d.pagePadding,
                vertical: d.sectionSpacing,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      d.screenH -
                      d.safeTop -
                      d.safeBottom -
                      d.sectionSpacing * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(d.radiusSM),
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: d.iconLG + 4,
                            height: d.iconLG + 4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Monity',
                          style: TextStyle(
                            fontSize: d.fontLG,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMain,
                          ),
                        ),
                      ],
                    ),

                    // Middle — headline + features
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: d.sectionSpacing * 2),
                        Text(
                          'Kelola Keuangan',
                          style: TextStyle(
                            fontSize: d.font3XL,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMain,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Lebih Cerdas.',
                          style: TextStyle(
                            fontSize: d.font3XL,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: d.sectionSpacing),
                        _featureRow(d, 'Lacak setiap pengeluaran otomatis'),
                        SizedBox(height: d.itemSpacing),
                        _featureRow(d, 'Analisis cerdas AI untuk tabungan'),
                        SizedBox(height: d.itemSpacing),
                        _featureRow(d, 'Keamanan data enkripsi perbankan'),
                      ],
                    ),

                    // Bottom — auth card
                    Column(
                      children: [
                        SizedBox(height: d.sectionSpacing * 1.5),
                        Container(
                          padding: EdgeInsets.all(d.sectionSpacing),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(d.radiusXL),
                            border: Border.all(
                              color: AppTheme.borderSide.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Google Sign-In
                              CustomButton(
                                text: _isLoading
                                    ? 'Memproses...'
                                    : 'Masuk dengan Google',
                                icon: _isLoading
                                    ? SizedBox(
                                        width: d.iconSM,
                                        height: d.iconSM,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.onPrimary,
                                        ),
                                      )
                                    : Icon(Icons.g_mobiledata, size: d.iconLG),
                                onPressed: _isLoading
                                    ? null
                                    : _handleGoogleSignIn,
                              ),
                              SizedBox(height: d.sectionSpacing),

                              // Terms
                              Text.rich(
                                TextSpan(
                                  text: 'Dengan melanjutkan, Anda menyetujui\n',
                                  style: TextStyle(
                                    fontSize: d.fontSM,
                                    color: AppTheme.textMuted,
                                    height: 1.6,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Ketentuan Layanan',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' & '),
                                    TextSpan(
                                      text: 'Privasi',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' kami.'),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(AppDimensions d, String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppTheme.primary, size: d.iconSM + 2),
        SizedBox(width: d.itemSpacing),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: d.fontMD,
              color: AppTheme.textMain,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
        ),
      ],
    );
  }
}
