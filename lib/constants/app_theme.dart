import 'package:flutter/material.dart';

class AppColors {
  // Ana Turuncu Tonları
  static const Color primary = Color(0xFFFF6D00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFFA040);
  static const Color primaryVeryLight = Color(0xFFFFF3E0);

  // Accent
  static const Color accent = Color(0xFFFF9100);

  // Beyaz / Nötr
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFF8F0);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFAF5);

  // Metin
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);

  // Durum Renkleri
  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFC107);
  static const Color statusDanger = Color(0xFFF44336);
  static const Color statusInfo = Color(0xFF2196F3);
  static const Color statusEarly = Color(0xFFFF7043);
  static const Color statusNeutral = Color(0xFF9E9E9E);

  // Divider
  static const Color divider = Color(0xFFFFE0B2);

  // Gradient
  static const Color gradientStart = Color(0xFFFF6D00);
  static const Color gradientEnd = Color(0xFFFFA040);

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}

class AppDimens {
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double cardRadius = 16;
  static const double cardElevation = 4;

  static const double buttonRadius = 12;
  static const double buttonHeight = 52;

  static const double textTitle = 22;
  static const double textSubtitle = 16;
  static const double textBody = 14;
  static const double textCaption = 12;
  static const double textLargeNumber = 28;

  static const double toolbarHeight = 56;

  static const double iconSizeSm = 24;
  static const double iconSizeMd = 36;
  static const double iconSizeLg = 48;
}
