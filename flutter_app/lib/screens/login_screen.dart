import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/design_system/sketch_card.dart';
import '../core/design_system/sketch_button.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني وكلمة السر'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(email, password, remember: _rememberMe);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await context.read<DataProvider>().loadAll();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMsg = auth.errorMessage ?? 'بيانات الدخول غير صحيحة';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showServerConfigDialog() {
    final auth = context.read<AuthProvider>();
    final urlController = TextEditingController(text: auth.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'عنوان الخادم (Server URL)',
          style: GoogleFonts.lemonada(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل رابط خادم دوّنلي (محلي أو سحابي):',
              style: GoogleFonts.tajawal(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'مثال: http://192.168.1.50:3000',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => urlController.text = AppConstants.defaultLocalUrl,
                  child: const Text('localhost', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => urlController.text = AppConstants.defaultServerUrl,
                  child: const Text('10.0.2.2 (Emulator)', style: TextStyle(fontSize: 12)),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          SketchButton.primary(
            text: 'حفظ',
            isSmall: true,
            onPressed: () async {
              await auth.setBaseUrl(urlController.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: SketchCard(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الشعار
                    SvgPicture.asset(
                      'assets/logo/dawwenli-logo.svg',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),

                    // النص الترحيبي
                    Text(
                      'أهلاً بيك تاني — سجّل دخولك تكمّل دفترك',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // حقل الإيميل
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'الإيميل',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        hintTextDirection: TextDirection.ltr,
                        filled: true,
                        fillColor: AppColors.surfaceRaised,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.hairline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // حقل كلمة السر
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'كلمة السر',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        filled: true,
                        fillColor: AppColors.surfaceRaised,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.hairline),
                        ),
                        suffixIcon: IconButton(
                          icon: Text(
                            _obscurePassword ? '👁️' : '🙈',
                            style: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // تذكّرني
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.brand,
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        Text(
                          'فكّرني (سيبني داخل ٣٠ يوم)',
                          style: GoogleFonts.tajawal(
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // زر تسجيل الدخول الرئيسي
                    SizedBox(
                      width: double.infinity,
                      child: SketchButton.primary(
                        text: 'دخول',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الدخول مباشرة للمعاينة
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Text(
                        'الدخول المباشر إلى التطبيق (بدون حساب)',
                        style: GoogleFonts.tajawal(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.brandDeep,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.hairline),
                    const SizedBox(height: 8),

                    // تذييل الكارت
                    Text(
                      'دوّنلي — احكِ لي يومك وأنا أرتّبه ✎',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 11.5,
                        color: AppColors.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showServerConfigDialog,
                      child: Text(
                        '⚙️ ضبط عنوان الخادم',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: AppColors.inkFaint,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
