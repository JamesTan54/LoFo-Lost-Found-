import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    _isInitialized = true;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      // 1. Minta izin Notifikasi untuk Android (jika di Android)
      if (!kIsWeb) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'lofo_channel',
        'Laporan LoFo',
        channelDescription: 'Notifikasi status laporan barang',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      // 2. Tampilkan Notifikasi
      await _notificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      // Menjaga agar jika notifikasi ditolak/tidak didukung (seperti di Web),
      // proses pengiriman laporan di aplikasi TETAP SUKSES tanpa error merah.
      debugPrint('Notifikasi diblokir atau tidak didukung: $e');
    }
  }
}