import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/check_in_out_request.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// activity_qr_checkin.xml birebir karşılığı
class QrCheckInScreen extends StatefulWidget {
  const QrCheckInScreen({super.key});
  @override
  State<QrCheckInScreen> createState() => _QrCheckInScreenState();
}

class _QrCheckInScreenState extends State<QrCheckInScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  double _lat = 0, _lng = 0;
  bool _locReady = false, _processing = false;
  String _scanStatus = 'QR kod bekleniyor...';
  String _scanLocInfo = 'Konum alınıyor...';
  String _scanResult = '';
  String _genLocInfo = 'Konum alınıyor...';
  String _qrData = '';
  int _countdown = 0;
  Timer? _timer;
  StreamSubscription<Position>? _posSub;
  static const _validity = 30;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() { if (_tab.index == 1 && _qrData.isEmpty) _genQr(); });
    _requestLoc();
  }

  Future<void> _requestLoc() async {
    final p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
    _posSub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5))
        .listen((pos) {
      if (pos.isMocked) { setState(() => _locReady = false); return; }
      setState(() {
        _lat = pos.latitude; _lng = pos.longitude; _locReady = true;
        final info = 'Konum hazır (±${pos.accuracy.toStringAsFixed(0)}m)';
        _scanLocInfo = info; _genLocInfo = info;
      });
      if (pos.accuracy <= 50) _posSub?.cancel();
    });
  }

  void _onDetect(BarcodeCapture c) {
    if (_processing) return;
    final code = c.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _processing = true;
    _sendScan(code);
  }

  Future<void> _sendScan(String qr) async {
    setState(() => _scanStatus = AppStrings.qrScannedProcessing);
    if (!_locReady) { await Future.delayed(const Duration(seconds: 3)); if (!_locReady) { setState(() { _scanStatus = AppStrings.locationWaiting; _processing = false; }); return; } }
    try {
      final devId = await sessionManager.getDeviceId();
      final req = CheckInOutRequest(personnelId: sessionManager.personnelId, latitude: _lat, longitude: _lng, qrCode: qr, type: CheckInType.qrScan, deviceId: devId);
      final resp = await apiService.qrCheckInOut(req);
      if (mounted) setState(() {
        _scanResult = resp.success ? AppStrings.checkinSuccess : (resp.message ?? 'Hata');
        _scanStatus = resp.success ? AppStrings.qrOperationComplete : _scanStatus;
        if (!resp.success) Future.delayed(const Duration(seconds: 3), () { _processing = false; });
      });
    } catch (e) { if (mounted) setState(() { _scanResult = 'Hata: $e'; _processing = false; }); }
  }

void _genQr() {
    _timer?.cancel();

    // 1. C# tarafıyla tamamen aynı olması gereken gizli anahtarınız
    const String secretKey = "ErdemPdks_2026_!SecureKey";
    
    // 2. Dinamik veriler
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final int personnelId = sessionManager.personnelId;

    // 3. Güvenlik İmzası (Hash) Oluşturma
    // Personel ID, Timestamp ve SecretKey'i birleştirip SHA-256 ile şifreliyoruz.
    final String rawData = "$personnelId$ts$secretKey";
    final bytes = utf8.encode(rawData);
    final String signature = sha256.convert(bytes).toString(); // Küçük harflerle hex formatında imza üretir

    setState(() {
      // 4. Yeni güvenli QR Formatı: PDKS_CHECKIN | PersonelId | İmza | Timestamp
      _qrData = 'PDKS_CHECKIN|$personnelId|$signature|$ts';
      _countdown = _validity;
    });

    // Geri sayım sayacı
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) { 
        t.cancel(); 
        setState(() { _countdown = 0; _qrData = ''; }); 
      }
      else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() { _tab.dispose(); _timer?.cancel(); _posSub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(AppStrings.titleQrCheckin),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white, tabs: const [Tab(text: AppStrings.tabQrScan), Tab(text: AppStrings.tabQrGenerate)]),
      ),
      body: TabBarView(controller: _tab, children: [_scanTab(), _genTab()]),
    );
  }

  Widget _scanTab() => Column(children: [
    Expanded(child: Stack(children: [
      MobileScanner(
        onDetect: _onDetect,
        errorBuilder: (context, error, child) {
          return Center(
            child: Text('Kamera başlatılamadı:\n${error.errorDetails?.message ?? error.errorCode}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          );
        },
      ),      Positioned(top: 0, left: 0, right: 0, child: Container(
        color: Colors.black54, padding: const EdgeInsets.all(AppDimens.spacingMd),
        child: const Text('Giriş kapısındaki QR kodu okutun', textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: AppDimens.textBody)),
      )),
    ])),
    Container(color: AppColors.white, padding: const EdgeInsets.all(AppDimens.spacingMd), child: Column(children: [
      Text(_scanStatus, style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(_scanLocInfo, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
      if (_scanResult.isNotEmpty) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm),
          child: Text(_scanResult, textAlign: TextAlign.center, style: TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold,
              color: _scanResult.contains('Gönderildi') ? AppColors.statusSuccess : AppColors.statusDanger))),
    ])),
  ]);

  Widget _genTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppDimens.spacingLg),
    child: Column(children: [
      const Text('Telefonunuzu kapıdaki okuyucuya gösterin', textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: AppDimens.spacingLg),
      // QR kart
      Material(color: AppColors.white, borderRadius: BorderRadius.circular(16), elevation: 4,
        child: SizedBox(width: 280, height: 280, child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          child: _qrData.isNotEmpty && _countdown > 0
              ? QrImageView(data: _qrData, version: QrVersions.auto, size: 248)
              : const Center(child: Icon(Icons.qr_code, size: 100, color: AppColors.textHint)),
        )),
      ),
      const SizedBox(height: AppDimens.spacingMd),
      Text(_genLocInfo, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingSm),
      if (_countdown > 0)
        Text(AppStrings.qrTimerValidity(_countdown),
            style: TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: _countdown <= 10 ? AppColors.statusDanger : AppColors.primary))
      else if (_qrData.isEmpty && _countdown == 0)
        const Text('')
      else
        Text(AppStrings.qrTimerExpired, style: const TextStyle(color: AppColors.statusDanger, fontWeight: FontWeight.bold)),
      const SizedBox(height: AppDimens.spacingMd),
      SizedBox(width: 200, height: AppDimens.buttonHeight, child: ElevatedButton(onPressed: _genQr, child: const Text('YENİ QR OLUŞTUR'))),
    ]),
  );
}
