import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// layout_toolbar.xml karşılığı
class PdksToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const PdksToolbar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimens.toolbarHeight);
}

/// bg_card_rounded.xml — beyaz yuvarlatılmış kart
class PdksCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const PdksCard({super.key, required this.child, this.padding, this.margin, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDimens.spacingSm),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: const Color(0x22FF6D00),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimens.spacingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Patron dashboard - sol renkli çizgili menü kartı
class MenuCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const MenuCard({super.key, required this.accentColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PdksCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(
            color: accentColor, borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(width: AppDimens.spacingSm),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            ]),
          ),
          const Icon(Icons.play_arrow, size: AppDimens.iconSizeSm, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// Özet kutu (sayı + etiket) — patron dashboard gridleri
class SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;
  const SummaryBox({super.key, required this.label, required this.value, required this.valueColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: TextStyle(fontSize: AppDimens.textLargeNumber, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

/// Durum badge
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String text;
    switch (status) {
      case 'approved': bg = const Color(0xFFE8F5E9); fg = AppColors.statusSuccess; text = 'Onaylandı';
      case 'rejected': bg = const Color(0xFFFFEBEE); fg = AppColors.statusDanger; text = 'Reddedildi';
      case 'pending': bg = const Color(0xFFFFF8E1); fg = AppColors.statusWarning; text = 'Bekliyor';
      case 'normal': bg = const Color(0xFFE8F5E9); fg = AppColors.statusSuccess; text = 'Normal';
      case 'late': bg = const Color(0xFFFFEBEE); fg = AppColors.statusDanger; text = 'Geç';
      case 'early': bg = const Color(0xFFFBE9E7); fg = AppColors.statusEarly; text = 'Erken Çıkış';
      case 'absent': bg = const Color(0xFFFFEBEE); fg = AppColors.statusDanger; text = 'Devamsız';
      case 'leave': case 'on_leave': bg = const Color(0xFFE3F2FD); fg = AppColors.statusInfo; text = 'İzinli';
      case 'active': bg = const Color(0xFFE8F5E9); fg = AppColors.statusSuccess; text = 'Aktif';
      default: bg = const Color(0xFFF5F5F5); fg = AppColors.statusNeutral; text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

/// Boş durum
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXl),
        child: Text(message, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: AppDimens.textBody, color: AppColors.textSecondary)),
      ),
    );
  }
}

/// Turuncu gradient kutu (bg_gradient_orange.xml)
class GradientBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  const GradientBox({super.key, required this.child, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: borderRadius),
      child: child,
    );
  }
}
