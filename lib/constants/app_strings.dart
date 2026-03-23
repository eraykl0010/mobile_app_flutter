class AppStrings {
  // Ortak
  static const String appName = 'OnlinePDKS';
  static String welcome(String name) => 'Hoş geldiniz, $name';
  static const String errorConnection = 'Bağlantı hatası';
  static const String errorNoInternet = 'İnternet bağlantısı yok';
  static String errorServer(int code) => 'Sunucu hatası (HTTP $code)';
  static const String errorSubmitFailed = 'Talep gönderilemedi';
  static const String errorSessionExpired = 'Oturumunuz sona erdi, lütfen tekrar giriş yapın';
  static const String checkinSuccess = 'Giriş / Çıkış Kaydı Gönderildi.';
  static const String tabNewRequest = 'Yeni Talep';
  static const String tabHistory = 'Geçmiş Talepler';

  // Durum
  static const String statusApproved = 'Onaylandı';
  static const String statusRejected = 'Reddedildi';
  static const String statusPending = 'Bekliyor';

  // Login
  static const String modulePatron = 'Patron Modülü';
  static const String modulePersonel = 'Personel Modülü';
  static const String errorCompanyCodeRequired = 'Şirket kodu gerekli';
  static const String errorCardNoRequired = 'Personel kart no gerekli';
  static const String deviceRestrictionTitle = 'Cihaz Kısıtlaması';
  static const String deviceRestrictionMessage =
      'Bu cihaz başka bir personele kayıtlıdır veya bu hesap başka bir cihaza bağlıdır. Lütfen yöneticinize başvurun.';

  // Toolbar
  static const String titleLocationCheckin = 'Konum ile Giriş/Çıkış';
  static const String titleQrCheckin = 'QR + Konum Giriş/Çıkış';
  static const String titleAttendanceReport = 'Giriş-Çıkış Raporu';
  static const String titleLeaveRequest = 'İzin Talebi';
  static const String titleAdvanceRequest = 'Avans Talebi';
  static const String titleMonthlyOvertime = 'Aylık Mesai Bilgisi';
  static const String titlePersonnelDetail = 'Personel Bilgi Kartı';
  static const String titleLateEarly = 'Fazla Mesai / Eksik Mesai';
  static const String titleAnnualLeave = 'Yıllık İzin Talepleri';
  static const String titleDailyLeave = 'Günlük İzin Talepleri';
  static const String titleHourlyLeave = 'Saatlik İzin Talepleri';
  static const String titleAdvanceApproval = 'Avans Talepleri';

  // Konum
  static const String locationReady = 'Konum hazır';
  static const String locationNotReady = 'Konum henüz alınamadı';
  static const String locationPermissionRequired = 'Konum izni gerekli';
  static const String locationWaiting = 'Konum bekleniyor…';
  static const String locationMockDetected = 'Sahte konum tespit edildi!';

  // QR
  static const String tabQrScan = 'QR Okut';
  static const String tabQrGenerate = 'QR Oluştur';
  static const String qrScannedProcessing = 'QR okundu — işleniyor…';
  static const String qrOperationComplete = 'İşlem tamamlandı';
  static const String qrGenerateFailed = 'QR oluşturulamadı';
  static String qrTimerValidity(int sec) => 'Geçerlilik: $sec sn';
  static const String qrTimerExpired = 'Süre doldu — yeniden oluşturun';
  static const String cameraStartFailed = 'Kamera başlatılamadı';
  static const String cameraLocationPermRequired = 'Kamera ve konum izni gerekli';

  // İzin
  static const String leaveRequestSent = 'İzin talebi gönderildi';
  static const String errorStartDateRequired = 'Başlangıç tarihi seçin';
  static const String errorEndDateRequired = 'Bitiş tarihi seçin';
  static const String errorTimeRangeRequired = 'Saat aralığı seçin';

  // Avans
  static const String advanceRequestSent = 'Avans talebi gönderildi';
  static const String errorAmountRequired = 'Tutar girin';
  static const String errorAmountInvalid = 'Geçerli bir tutar girin';
  static const String errorAmountPositive = 'Tutar sıfırdan büyük olmalı';
  static const String advanceHistoryEmpty = 'Henüz avans talebi bulunmuyor';

  // Rapor
  static const String tabDaily = 'Günlük';
  static const String tabWeekly = 'Haftalık';

  // Onay
  static const String tabPending = 'Bekleyen';
  static const String tabApproved = 'Onaylanan';
  static const String tabRejected = 'Reddedilen';
  static const String emptyPending = 'Bekleyen talep bulunmuyor';
  static const String emptyApproved = 'Onaylanan talep bulunmuyor';
  static const String emptyRejected = 'Reddedilen talep bulunmuyor';
  static const String confirmApproveTitle = 'Onay';
  static const String confirmRejectTitle = 'Red';
  static const String confirmApproveLeave = 'Bu izin talebini onaylamak istiyor musunuz?';
  static const String confirmRejectLeave = 'Bu izin talebini reddetmek istiyor musunuz?';
  static const String confirmApproveAdvance = 'Bu avans talebini onaylamak istiyor musunuz?';
  static const String confirmRejectAdvance = 'Bu avans talebini reddetmek istiyor musunuz?';
  static const String tabOvertime = 'Fazla Mesai';
  static const String tabUndertime = 'Eksik Mesai';
  static const String emptyOvertime = 'Dün fazla mesai yapan personel yok';
  static const String emptyUndertime = 'Dün eksik mesaisi olan personel yok';

  // Dashboard
  static const String allDepartments = 'Tüm Departmanlar';
  static const String logoutTitle = 'Çıkış';
  static const String logoutMessage = 'Oturumu kapatmak istediğinize emin misiniz?';
  static const String btnYes = 'Evet';
  static const String btnCancel = 'İptal';
  static const String btnOk = 'Tamam';

  // Personel Detay
  static const String personnelListTitle = 'Personel Listesi';
  static const String deviceResetOption = 'Cihaz Kaydını Sıfırla';
  static String deviceResetMessage(String name) =>
      '$name adlı personelin cihaz kaydı silinecek.\n\nPersonel bir sonraki girişte yeni cihazına otomatik kaydedilecektir.\n\nDevam etmek istiyor musunuz?';
  static String deviceResetSuccess(String name) => '$name — cihaz kaydı sıfırlandı';
  static const String deviceResetFailed = 'İşlem başarısız';
}
