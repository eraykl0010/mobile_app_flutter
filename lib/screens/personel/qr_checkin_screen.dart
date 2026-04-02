import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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

class _QrCheckInScreenState extends State<QrCheckInScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  Timer? _locTimeout;
  bool _locDialogShown = false;
  bool _isRequestingLoc = false;
  bool _cameraAllowed = false;
  static const _validity = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() { if (_tab.index == 1 && _qrData.isEmpty) _genQr(); });
    _initPermissions();
  }

  /// Kamera ve konum izinlerini sıralı olarak iste
  Future<void> _initPermissions() async {
    // 1. Önce kamera izni
    await _requestCameraPermission();
    // 2. Sonra konum izni (kamera sonucundan bağımsız)
    await _requestLoc();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (mounted) {
      setState(() => _cameraAllowed = status.isGranted || status.isLimited);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _posSub?.cancel();
      _timer?.cancel();
      _locTimeout?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // Ön plana dönünce izinleri sessizce kontrol et
      _silentPermissionCheck();
    }
  }

  /// Kullanıcı ayarlardan izin verdiyse güncelle — dialog göstermeden
  Future<void> _silentPermissionCheck() async {
    // Kamera izni kontrolü
    if (!_cameraAllowed) {
      final camStatus = await Permission.camera.status;
      if (mounted && (camStatus.isGranted || camStatus.isLimited)) {
        setState(() => _cameraAllowed = true);
      }
    }

    // Konum izni kontrolü
    if (!_locReady && !_isRequestingLoc) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final p = await Geolocator.checkPermission();
      if (p == LocationPermission.whileInUse || p == LocationPermission.always) {
        _locDialogShown = false;
        _startLocStream();
      }
    }
  }

  Future<void> _requestLoc() async {
    if (_isRequestingLoc) return;
    _isRequestingLoc = true;
    try {
      // Konum servisi açık mı kontrol et
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _scanLocInfo = 'Konum servisi kapalı';
            _genLocInfo = 'Konum servisi kapalı';
          });
          if (!_locDialogShown) {
            _showLocationDialog(
              title: 'Konum Servisi Kapalı',
              message: 'Giriş/çıkış işlemi yapabilmek için cihazınızın konum servisini açmanız gerekmektedir.',
            );
          }
        }
        return;
      }

      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }

      if (p == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _scanLocInfo = 'Konum izni reddedildi';
            _genLocInfo = 'Konum izni reddedildi';
          });
          if (!_locDialogShown) {
            _showLocationDialog(
              title: 'Konum İzni Gerekli',
              message: 'QR ile giriş/çıkış yapabilmek için konum iznine ihtiyaç vardır. Lütfen izin verin.',
              showRetry: true,
            );
          }
        }
        return;
      }

      if (p == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _scanLocInfo = 'Konum izni kalıcı olarak reddedildi';
            _genLocInfo = 'Konum izni kalıcı olarak reddedildi';
          });
          if (!_locDialogShown) {
            _showLocationDialog(
              title: 'Konum İzni Gerekli',
              message: 'Konum izni kalıcı olarak reddedilmiş. Lütfen uygulama ayarlarından konum iznini etkinleştirin.',
              showSettings: true,
            );
          }
        }
        return;
      }

      // İzin verildi — stream başlat
      _startLocStream();
    } finally {
      _isRequestingLoc = false;
    }
  }

  /// Konum stream'ini başlat (izin kontrolü yapılmış varsayılır)
  void _startLocStream() {
    _posSub?.cancel();
    _locTimeout?.cancel();

    _posSub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((pos) {
      if (pos.isMocked) {
        setState(() {
          _locReady = false;
          _scanLocInfo = AppStrings.locationMockDetected;
          _genLocInfo = AppStrings.locationMockDetected;
        });
        return;
      }
      setState(() {
        _lat = pos.latitude; _lng = pos.longitude; _locReady = true;
        final info = 'Konum hazır (±${pos.accuracy.toStringAsFixed(0)}m)';
        _scanLocInfo = info; _genLocInfo = info;
      });
      if (pos.accuracy <= 100) {
        _posSub?.cancel();
        _locTimeout?.cancel();
      }
    });

    _locTimeout = Timer(const Duration(seconds: 30), () {
      if (!_locReady) {
        _posSub?.cancel();
        if (mounted) setState(() {
          _scanLocInfo = 'Konum alınamadı';
          _genLocInfo = 'Konum alınamadı';
        });
      }
    });
  }

  void _showLocationDialog({required String title, required String message, bool showRetry = false, bool showSettings = false}) {
    _locDialogShown = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showSettings)
            TextButton(
              onPressed: () { Navigator.pop(context); Geolocator.openAppSettings(); },
              child: const Text('Ayarları Aç'),
            ),
          if (showRetry)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _locDialogShown = false;
                _requestLoc();
              },
              child: const Text('Tekrar Dene'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.btnOk),
          ),
        ],
      ),
    );
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
    } catch (e) { if (mounted) setState(() { _scanResult = 'İşlem sırasında bir hata oluştu. Lütfen tekrar deneyin.'; _processing = false; }); }
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tab.dispose();
    _timer?.cancel();
    _posSub?.cancel();
    _locTimeout?.cancel();
    super.dispose();
  }

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
    Expanded(child: _cameraAllowed
      ? Stack(children: [
          MobileScanner(
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Container(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.spacingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.white, size: 64),
                        const SizedBox(height: AppDimens.spacingMd),
                        const Text('Kamera Başlatılamadı',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimens.spacingSm),
                        Text('Kamera açılırken bir sorun oluştu. Lütfen tekrar deneyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: AppDimens.textBody),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(top: 0, left: 0, right: 0, child: Container(
            color: Colors.black54, padding: const EdgeInsets.all(AppDimens.spacingMd),
            child: const Text('Giriş kapısındaki QR kodu okutun', textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: AppDimens.textBody)),
          )),
        ])
      : _cameraPermissionDeniedWidget(),
    ),
    Container(color: AppColors.white, padding: const EdgeInsets.all(AppDimens.spacingMd), child: Column(children: [
      Text(_scanStatus, style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(_scanLocInfo, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
      if (_scanResult.isNotEmpty) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm),
          child: Text(_scanResult, textAlign: TextAlign.center, style: TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold,
              color: _scanResult.contains('Gönderildi') ? AppColors.statusSuccess : AppColors.statusDanger))),
    ])),
  ]);

  Widget _cameraPermissionDeniedWidget() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, color: AppColors.white, size: 64),
              const SizedBox(height: AppDimens.spacingMd),
              const Text('Kamera İzni Gerekli',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.spacingSm),
              Text(
                'QR kod okutabilmek için kamera iznine ihtiyaç vardır.\nLütfen uygulama ayarlarından kamera iznini etkinleştirin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: AppDimens.textBody),
              ),
              const SizedBox(height: AppDimens.spacingLg),
              SizedBox(
                width: 200,
                height: AppDimens.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => openAppSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Ayarları Aç'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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