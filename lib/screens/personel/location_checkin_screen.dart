import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/check_in_out_request.dart';
import '../../widgets/common_widgets.dart';

/// activity_location_checkin.xml birebir karşılığı
class LocationCheckInScreen extends StatefulWidget {
  const LocationCheckInScreen({super.key});
  @override
  State<LocationCheckInScreen> createState() => _LocationCheckInScreenState();
}

class _LocationCheckInScreenState extends State<LocationCheckInScreen> with WidgetsBindingObserver {
  double _lat = 0, _lng = 0;
  bool _locationReady = false, _isLoading = false, _btnEnabled = false;
  String _status = 'Konum alınıyor...';
  String _locationInfo = 'Koordinatlar bekleniyor';
  String _currentTime = '--:--';
  String _result = '';
  Color _resultColor = AppColors.statusSuccess;
  Timer? _clock;
  StreamSubscription<Position>? _posSub;
  Timer? _locTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startClock();
    _requestLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Arka plana geçince kaynakları durdur
      _clock?.cancel();
      _posSub?.cancel();
      _locTimeout?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // Ön plana dönünce tekrar başlat
      _startClock();
      if (!_locationReady) _requestLocation();
    }
  }

  void _startClock() {
    _tick();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final n = DateTime.now();
    if (mounted) setState(() => _currentTime = '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}');
  }

  Future<void> _requestLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) { setState(() => _status = 'Konum servisi kapalı'); return; }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) { setState(() => _status = AppStrings.locationPermissionRequired); return; }

    _posSub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((pos) {
      if (pos.isMocked) { setState(() { _status = AppStrings.locationMockDetected; _locationReady = false; _btnEnabled = false; }); return; }
      setState(() {
        _lat = pos.latitude; _lng = pos.longitude; _locationReady = true; _btnEnabled = true;
        _status = AppStrings.locationReady;
        _locationInfo = '${_lat.toStringAsFixed(6)}, ${_lng.toStringAsFixed(6)} (±${pos.accuracy.toStringAsFixed(0)}m)';
      });
      // Yeterli doğruluk sağlandığında stream'i kapat — pil tasarrufu
      if (pos.accuracy <= 100) {
        _posSub?.cancel();
        _locTimeout?.cancel();
      }
    });

    // 30 saniye içinde konum alınamazsa stream'i kapat
    _locTimeout = Timer(const Duration(seconds: 30), () {
      if (!_locationReady) {
        _posSub?.cancel();
        if (mounted) setState(() => _status = 'Konum alınamadı. Tekrar denemek için geri dönüp tekrar açın.');
      }
    });
  }

  Future<void> _doCheckIn() async {
    if (!_locationReady) return;
    setState(() { _btnEnabled = false; _isLoading = true; });
    try {
      final devId = await sessionManager.getDeviceId();
      final req = CheckInOutRequest(personnelId: sessionManager.personnelId, latitude: _lat, longitude: _lng, type: CheckInType.location, deviceId: devId);
      final resp = await apiService.checkInOut(req);
      if (mounted) {
        setState(() { _result = resp.success ? AppStrings.checkinSuccess : (resp.message ?? 'Hata'); _resultColor = resp.success ? AppColors.statusSuccess : AppColors.statusDanger; });
        if (resp.success) Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _btnEnabled = true); });
        else setState(() => _btnEnabled = true);
      }
    } catch (e) { if (mounted) setState(() { _result = 'İşlem sırasında bir hata oluştu. Lütfen tekrar deneyin.'; _resultColor = AppColors.statusDanger; _btnEnabled = true; }); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _posSub?.cancel();
    _locTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PdksToolbar(title: AppStrings.titleLocationCheckin),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingLg),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Durum ikonu — 120x120 gradient kutu
            Container(
              width: 120, height: 120, margin: const EdgeInsets.only(bottom: AppDimens.spacingLg),
              decoration: BoxDecoration(gradient: AppColors.orangeGradient),
              padding: const EdgeInsets.all(30),
              child: const Icon(Icons.my_location, color: AppColors.white, size: 60),
            ),

            Text(_status, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: _locationReady ? AppColors.textPrimary : AppColors.textSecondary)),
            const SizedBox(height: AppDimens.spacingSm),
            Text(_locationInfo, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.spacingLg),

            // Saat
            Text(_currentTime, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: AppDimens.spacingLg),

            // Buton
            SizedBox(width: 220, height: AppDimens.buttonHeight, child: ElevatedButton(
              onPressed: _btnEnabled && !_isLoading ? _doCheckIn : null,
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Text('GİRİŞ / ÇIKIŞ YAP'),
            )),

            if (_isLoading) const Padding(padding: EdgeInsets.only(top: AppDimens.spacingMd), child: CircularProgressIndicator(color: AppColors.primary)),

            if (_result.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: AppDimens.spacingMd),
              child: Text(_result, textAlign: TextAlign.center, style: TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: _resultColor)),
            ),
          ]),
        ),
      ),
    );
  }
}