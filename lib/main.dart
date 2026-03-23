import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_theme.dart';
import 'services/session_manager.dart';
import 'services/api_service.dart';
import 'screens/module_selection_screen.dart';
import 'screens/personel/personel_dashboard_screen.dart';
import 'screens/patron/patron_dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

late SessionManager sessionManager;
late ApiService apiService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('tr_TR', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primaryDark,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  sessionManager = SessionManager();
  await sessionManager.init();
  apiService = ApiService(sessionManager);

  runApp(const OnlinePDKSApp());
}

class OnlinePDKSApp extends StatelessWidget {
  const OnlinePDKSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlinePDKS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.cardBackground,
          onPrimary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.buttonRadius)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          hintStyle: const TextStyle(color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd, vertical: 14),
        ),
        dividerColor: AppColors.divider,
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (sessionManager.isPersonelLocked) return const PersonelDashboardScreen();
    if (sessionManager.isPatronLoggedIn) return const PatronDashboardScreen();
    return const ModuleSelectionScreen();
  }
}
