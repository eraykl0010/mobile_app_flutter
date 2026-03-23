import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/login_request.dart';
import '../main.dart';
import 'personel/personel_dashboard_screen.dart';
import 'patron/patron_dashboard_screen.dart';

/// activity_login.xml birebir karşılığı
class LoginScreen extends StatefulWidget {
  final String moduleType;
  const LoginScreen({super.key, required this.moduleType});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _companyCtrl = TextEditingController();
  final _cardNoCtrl = TextEditingController();
  bool _isLoading = false;

  bool get _isPatron => widget.moduleType == ModuleType.patron;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Üst gradient — 240dp
          Container(height: 240, width: double.infinity, decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),

          SafeArea(
            child: Column(
              children: [
                // Geri butonu
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
                    ),
                  ),
                ),

                // Başlık — gradient üstünde
                const SizedBox(height: 16),
                const Text('Giriş Yap', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white)),
                const SizedBox(height: 8),
                Text(_isPatron ? AppStrings.modulePatron : AppStrings.modulePersonel,
                    style: TextStyle(fontSize: AppDimens.textBody, color: AppColors.white.withOpacity(0.8))),

                const SizedBox(height: 32),

                // Login kartı — 180dp marginTop (gradient üstüne biner)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
                    child: Column(children: [
                      Material(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.spacingLg),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Şirket Kodu
                            const Text('Şirket Kodu', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: AppDimens.spacingSm),
                            TextField(
                              controller: _companyCtrl,
                              decoration: const InputDecoration(hintText: 'Şirket kodunuzu girin'),
                              maxLines: 1,
                            ),
                            const SizedBox(height: AppDimens.spacingMd),

                            // Personel Kart No
                            const Text('Personel Kart No (Şifre)', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: AppDimens.spacingSm),
                            TextField(
                              controller: _cardNoCtrl,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'Personel kart numaranızı girin'),
                              maxLines: 1,
                            ),
                            const SizedBox(height: AppDimens.spacingLg),

                            // Giriş butonu
                            SizedBox(
                              width: double.infinity,
                              height: AppDimens.buttonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _attemptLogin,
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                    : const Text('GİRİŞ YAP'),
                              ),
                            ),

                            // Progress
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: AppDimens.spacingMd),
                                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                              ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _attemptLogin() async {
    final company = _companyCtrl.text.trim();
    final cardNo = _cardNoCtrl.text.trim();
    if (company.isEmpty) { _showError(AppStrings.errorCompanyCodeRequired); return; }
    if (cardNo.isEmpty) { _showError(AppStrings.errorCardNoRequired); return; }

    setState(() => _isLoading = true);
    try {
      final deviceId = await sessionManager.getDeviceId();
      final deviceModel = await sessionManager.getDeviceModel();
      final macAddress = await sessionManager.getMacAddress();
      final request = LoginRequest(
        companyCode: company, cardNo: cardNo, deviceId: deviceId,
        deviceModel: deviceModel, moduleType: widget.moduleType, macAddress: macAddress,
      );
      final resp = await apiService.login(request);
      if (!mounted) return;

      if (resp.success) {
        if (_isPatron) {
          await sessionManager.createPatronSession(company, cardNo, resp.token ?? '', resp.personnelId, resp.personnelName ?? '');
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PatronDashboardScreen()), (_) => false);
        } else {
          await sessionManager.createPersonelSession(company, cardNo, resp.token ?? '', resp.personnelId, resp.personnelName ?? '');
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PersonelDashboardScreen()), (_) => false);
        }
      } else {
        final msg = resp.message ?? 'Giriş başarısız';
        if (msg.contains('cihaz') || msg.contains('device')) {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text(AppStrings.deviceRestrictionTitle),
            content: Text(msg),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.btnOk))],
          ));
        } else { _showError(msg); }
      }
    } catch (e) { if (mounted) _showError('Bağlantı hatası: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.statusDanger));
}
