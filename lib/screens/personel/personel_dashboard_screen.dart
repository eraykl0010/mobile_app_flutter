import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../widgets/common_widgets.dart';
import 'location_checkin_screen.dart';
import 'qr_checkin_screen.dart';
import 'attendance_report_screen.dart';
import 'leave_request_screen.dart';
import 'advance_request_screen.dart';
import 'monthly_overtime_screen.dart';

/// activity_personel_dashboard.xml birebir karşılığı
class PersonelDashboardScreen extends StatelessWidget {
  const PersonelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Üst bar — primary renk
            Container(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: AppDimens.toolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
                    child: Row(children: [
                      const Expanded(child: Text('Personel Paneli',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white))),
                    ]),
                  ),
                ),
              ),
            ),

            // Hoşgeldin
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppStrings.welcome(sessionManager.personnelName),
                    style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
            ),

            // İçerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
                child: Column(children: [
                  // ═══ GİRİŞ-ÇIKIŞ BUTONLARI — 2 kart yan yana ═══
                  Row(children: [
                    // Konum ile — primary renk
                    Expanded(child: _BigActionCard(
                      color: AppColors.primary,
                      icon: Icons.my_location,
                      label: 'Konum ile\nGiriş/Çıkış',
                      onTap: () => _go(context, const LocationCheckInScreen()),
                    )),
                    const SizedBox(width: AppDimens.spacingXs),
                    // QR + Konum — primary_dark renk
                    Expanded(child: _BigActionCard(
                      color: AppColors.primaryDark,
                      icon: Icons.camera_alt,
                      label: 'QR + Konum\nGiriş/Çıkış',
                      onTap: () => _go(context, const QrCheckInScreen()),
                    )),
                  ]),
                  const SizedBox(height: AppDimens.spacingSm),

                  // ═══ MENÜ KARTLARI — sol renkli çizgi ═══
                  MenuCard(
                    accentColor: AppColors.statusInfo,
                    title: 'Giriş-Çıkış Raporu',
                    subtitle: 'Günlük ve haftalık giriş-çıkış bilgileri',
                    onTap: () => _go(context, const AttendanceReportScreen()),
                  ),
                  MenuCard(
                    accentColor: AppColors.statusSuccess,
                    title: 'İzin Talebi',
                    subtitle: 'İzin talebi oluştur ve sonuçları görüntüle',
                    onTap: () => _go(context, const LeaveRequestScreen()),
                  ),
                  MenuCard(
                    accentColor: AppColors.accent,
                    title: 'Avans Talebi',
                    subtitle: 'Avans talebi oluştur ve sonuçları görüntüle',
                    onTap: () => _go(context, const AdvanceRequestScreen()),
                  ),
                  MenuCard(
                    accentColor: AppColors.statusWarning,
                    title: 'Aylık Mesai Bilgisi',
                    subtitle: 'Aylık toplam çalışma ve mesai saatleri',
                    onTap: () => _go(context, const MonthlyOvertimeScreen()),
                  ),
                  const SizedBox(height: AppDimens.spacingLg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext ctx, Widget screen) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
}

/// Üstteki büyük renkli kart (Konum/QR)
class _BigActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BigActionCard({required this.color, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        splashColor: Colors.white24,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          child: Column(children: [
            Icon(icon, color: AppColors.white, size: AppDimens.iconSizeLg),
            const SizedBox(height: AppDimens.spacingSm),
            Text(label, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.white)),
          ]),
        ),
      ),
    );
  }
}
