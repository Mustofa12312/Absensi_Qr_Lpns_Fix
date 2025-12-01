// lib/features/auth/views/login_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/controllers/theme_controller.dart';
import '../../../core/theme/theme_helper.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  late final AnimationController _anim;
  late final Animation<Offset> _slide;
  bool _visible = false;

  final authC = Get.find<AuthController>();
  final themeC = Get.find<ThemeController>();

  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _visible = true);
      _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await authC.login(emailCtrl.text, passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDark();
    final size = MediaQuery.of(context).size;

    // 🎨 Warna teks berdasarkan tema
    final txtPrimary = dark ? Colors.white : const Color(0xFF1C1C1E);
    final txtSecondary = dark ? Colors.white70 : const Color(0xFF3A3A3C);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌈 Background iOS Light / Dark
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? const [
                        Color(0xFF020617),
                        Color(0xFF0B1221),
                        Color(0xFF020617),
                      ]
                    : const [
                        Color(0xFFFFFFFF),
                        Color(0xFFF6F7FB),
                        Color(0xFFEFF1F5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌗 Theme toggle
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.15),
                  ),
                  icon: Icon(
                    dark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                    color: Colors.white,
                  ),
                  onPressed: themeC.toggleTheme,
                ),
              ),
            ),
          ),

          // 💎 Glass card iOS-style
          Center(
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: SlideTransition(
                position: _slide,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: size.width * 0.9,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.black.withOpacity(0.35)
                            : Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: dark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 56,
                            color: dark ? Colors.white : Color(0xFF1C1C1E),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            'Login Pengawas',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: txtPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Gunakan akun resmi yang diberikan',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: txtSecondary,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ✉ Email
                          _inputField(
                            controller: emailCtrl,
                            hint: 'Email',
                            icon: Icons.email_rounded,
                            dark: dark,
                            onSubmit: (_) {},
                          ),

                          const SizedBox(height: 16),

                          // 🔒 Password
                          _inputField(
                            controller: passCtrl,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            dark: dark,
                            obscure: !showPassword,
                            suffix: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: txtSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => showPassword = !showPassword),
                            ),
                            onSubmit: (_) => _login(),
                          ),

                          const SizedBox(height: 26),

                          // 🔘 Tombol Login
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authC.isLoading.value
                                    ? null
                                    : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: dark
                                      ? Colors.white.withOpacity(0.18)
                                      : Colors.black.withOpacity(0.07),
                                  foregroundColor: dark
                                      ? Colors.white
                                      : Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.2),
                                ),
                                child: authC.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        'Masuk',
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
          ),
        ],
      ),
    );
  }

  /// ✏ Input field iPhone-style
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool dark,
    bool obscure = false,
    Widget? suffix,
    required Function(String) onSubmit,
  }) {
    final txtPrimary = dark ? Colors.white : const Color(0xFF1C1C1E);

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: txtPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: dark ? Colors.white70 : const Color(0xFF8E8E93),
        ),
        prefixIcon: Icon(icon, color: txtPrimary),
        suffixIcon: suffix,
        filled: true,
        fillColor: dark
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.25)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: dark ? Colors.white : Colors.black87,
            width: 1.8,
          ),
        ),
      ),
      onSubmitted: onSubmit,
      textInputAction: TextInputAction.next,
    );
  }
}
