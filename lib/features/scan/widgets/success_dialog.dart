// lib/features/scan/widgets/success_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const SuccessDialog({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // lebih iPhone
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.65),
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.18)
                    : Colors.white.withOpacity(0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: dark
                      ? Colors.black.withOpacity(0.45)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON SUKSES versi Apple Pay style
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent.shade400.withOpacity(0.18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.shade400.withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: 1.2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.35,
                    color: dark ? Colors.white70 : const Color(0xFF3A3A3C),
                  ),
                ),

                const SizedBox(height: 24),

                // TOMBOL iOS style
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: dark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.black.withOpacity(0.85),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
