import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'services/session_manager.dart';
import 'services/api_service.dart';
import 'screens/module_selection_screen.dart';
import 'screens/personel/personel_dashboard_screen.dart';
import 'screens/patron/patron_dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

late SessionManager sessionManager;
late ApiService apiService;

/// Uygulama genelinde navigator erişimi (401 yönlendirmesi için)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ══════ Global Hata Yakalayıcı ══════
  // Flutter framework hataları (widget build, layout vs.)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Async hataları (Future, Timer vs.)
  runZonedGuarded(() async {
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

    // 401 oturum süresi dolduğunda login ekranına yönlendir
    apiService.onSessionExpired = () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        if (sessionManager.isPatron) {
          sessionManager.logoutPatron();
        } else {
          sessionManager.logoutPersonel();
        }
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ModuleSelectionScreen()),
          (_) => false,
        );
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorSessionExpired),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    };

    runApp(const OnlinePDKSApp());
  }, (error, stackTrace) {
    debugPrint('Yakalanmamış hata: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class OnlinePDKSApp extends StatelessWidget {
  const OnlinePDKSApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Release modda kırmızı hata ekranı yerine kullanıcı dostu ekran göster
    if (kReleaseMode) {
      ErrorWidget.builder = (details) => Material(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.statusWarning),
                const SizedBox(height: AppDimens.spacingMd),
                const Text('Bir sorun oluştu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: AppDimens.spacingSm),
                const Text('Lütfen uygulamayı yeniden başlatın.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'OnlinePDKS',
      navigatorKey: navigatorKey,
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