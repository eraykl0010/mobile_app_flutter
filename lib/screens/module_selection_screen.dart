import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';

/// activity_main.xml birebir karşılığı
class ModuleSelectionScreen extends StatelessWidget {
  const ModuleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Üst gradient header — 280dp
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.orangeGradient),
          ),

          SafeArea(
            child: Column(
              children: [
                // Başlık
                const SizedBox(height: 40),
                const Text('OnlinePDKS',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white)),
                const SizedBox(height: 8),
                Text('Personel Devam Kontrol Sistemi',
                    style: TextStyle(fontSize: AppDimens.textBody, color: AppColors.white.withOpacity(0.8))),

                const SizedBox(height: 60),

                // Kartlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
                  child: Column(children: [
                    // Patron Kartı
                    _ModuleCard(
                      icon: Icons.settings,
                      title: 'Patron Modülü',
                      subtitle: 'Personel takip, onay ve raporlama',
                      onTap: () => _go(context, ModuleType.patron),
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
                    // Personel Kartı
                    _ModuleCard(
                      icon: Icons.calendar_today,
                      title: 'Personel Modülü',
                      subtitle: 'Giriş-çıkış, izin talebi ve mesai',
                      onTap: () => _go(context, ModuleType.personel),
                    ),
                  ]),
                ),

                const Spacer(),

                // Alt logo alanı — kartlar ile alt çizgi arasında dikey orta
                Center(
                  child: Image.asset('assets/images/logo.png', height: 200),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.spacingMd),
                  child: Text('v1.0 © 2026 Online PDKS',
                      style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textHint)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, String module) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(moduleType: module)));
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModuleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      elevation: AppDimens.cardElevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        splashColor: const Color(0x22FF6D00),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingLg),
          child: Row(
            children: [
              // Icon gradient box — 56x56
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(14),
                child: Icon(icon, color: AppColors.white, size: 28),
              ),
              const SizedBox(width: AppDimens.spacingMd),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
                ]),
              ),
              const Icon(Icons.play_arrow, size: 24, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
