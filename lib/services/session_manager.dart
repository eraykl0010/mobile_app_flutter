import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_constants.dart';

class SessionManager {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyModuleType = 'module_type';
  static const _keyCompanyCode = 'company_code';
  static const _keyCardNo = 'card_no';
  static const _keyPersonnelId = 'personnel_id';
  static const _keyPersonnelName = 'personnel_name';
  static const _keyDeviceId = 'device_id';
  static const _keyIsPatron = 'is_patron';
  static const _keyToken = 'auth_token';
  static const _keyMacAddress = 'mac_address';

  late SharedPreferences _prefs;

  // Settings.Secure.ANDROID_ID okumak için native kanal
  static const _channel = MethodChannel('com.pdks.mobile/device');

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Eski hatalı Build ID cache'ini temizle
    final saved = _prefs.getString(_keyDeviceId);
    if (saved != null && saved.contains('.')) {
      await _prefs.remove(_keyDeviceId);
      await _prefs.remove(_keyMacAddress);
    }
  }

  // ══════════ CİHAZ TANIMLAYICI ══════════

  Future<String> getDeviceId() async {
    final saved = _prefs.getString(_keyDeviceId);
    if (saved != null && saved.isNotEmpty) return saved;

    String id;
    if (Platform.isAndroid) {
      // Settings.Secure.ANDROID_ID — Java kodundaki ile birebir aynı
      // Her cihaz + uygulama imzasına özel, donanım ID'si değil
      try {
        id = await _channel.invokeMethod<String>('getAndroidId') ?? 'unknown';
      } catch (_) {
        id = 'unknown_android';
      }
    } else if (Platform.isIOS) {
      final ios = await DeviceInfoPlugin().iosInfo;
      id = ios.identifierForVendor ?? 'unknown_ios';
    } else {
      id = 'unknown_platform';
    }

    await _prefs.setString(_keyDeviceId, id);
    return id;
  }

  Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await deviceInfo.androidInfo;
      return '${a.manufacturer} ${a.model}';
    } else if (Platform.isIOS) {
      final i = await deviceInfo.iosInfo;
      return '${i.name} ${i.model}';
    }
    return 'Unknown';
  }

  Future<String> getMacAddress() async {
    final saved = _prefs.getString(_keyMacAddress);
    if (saved != null && saved.isNotEmpty && !saved.contains('BP')) return saved;
    final devId = await getDeviceId();
    final id = 'AID_$devId';
    await _prefs.setString(_keyMacAddress, id);
    return id;
  }

  // ══════════ PATRON OTURUM ══════════

  Future<void> createPatronSession(String companyCode, String cardNo,
      String token, int personnelId, String name) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyModuleType, ModuleType.patron);
    await _prefs.setString(_keyCompanyCode, companyCode);
    await _prefs.setString(_keyCardNo, cardNo);
    await _prefs.setString(_keyToken, token);
    await _prefs.setInt(_keyPersonnelId, personnelId);
    await _prefs.setString(_keyPersonnelName, name);
    await _prefs.setBool(_keyIsPatron, true);
    await _prefs.setString(_keyMacAddress, await getMacAddress());
  }

  bool get isPatronLoggedIn => isLoggedIn && moduleType == ModuleType.patron;

  Future<void> logoutPatron() async {
    if (isPatron) {
      final devId = _prefs.getString(_keyDeviceId);
      final mac = _prefs.getString(_keyMacAddress);
      await _prefs.clear();
      if (devId != null) await _prefs.setString(_keyDeviceId, devId);
      if (mac != null) await _prefs.setString(_keyMacAddress, mac);
    }
  }

  // ══════════ PERSONEL OTURUM ══════════

  Future<void> createPersonelSession(String companyCode, String cardNo,
      String token, int personnelId, String name) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyModuleType, ModuleType.personel);
    await _prefs.setString(_keyCompanyCode, companyCode);
    await _prefs.setString(_keyCardNo, cardNo);
    await _prefs.setString(_keyToken, token);
    await _prefs.setInt(_keyPersonnelId, personnelId);
    await _prefs.setString(_keyPersonnelName, name);
    await _prefs.setBool(_keyIsPatron, false);
    final devId = await getDeviceId();
    await _prefs.setString(_keyDeviceId, devId);
    await _prefs.setString(_keyMacAddress, await getMacAddress());
  }

  bool get isPersonelLocked => isLoggedIn && moduleType == ModuleType.personel;

  // ══════════ GETTER'LAR ══════════

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  bool get isPatron => _prefs.getBool(_keyIsPatron) ?? false;
  String get moduleType => _prefs.getString(_keyModuleType) ?? '';
  String get companyCode => _prefs.getString(_keyCompanyCode) ?? '';
  String get cardNo => _prefs.getString(_keyCardNo) ?? '';
  String get token => _prefs.getString(_keyToken) ?? '';
  int get personnelId => _prefs.getInt(_keyPersonnelId) ?? -1;
  String get personnelName => _prefs.getString(_keyPersonnelName) ?? '';
}
