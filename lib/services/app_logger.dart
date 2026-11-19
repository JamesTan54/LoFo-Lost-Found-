import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  // Menyimpan maksimal 200 log terakhir di memori saat aplikasi running
  static final List<String> _logs = [];
  static List<String> get logs => List.unmodifiable(_logs);

  static void _record(
    String level,
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    final formatted = '[$timestamp] [$level] [$tag] $message';

    _logs.add(formatted);
    if (_logs.length > 200) {
      _logs.removeAt(0);
    }

    // Muncul di VS Code Debug Console & adb logcat Android saat running
    debugPrint(formatted);
    if (error != null) {
      debugPrint('[$timestamp] [DETAIL] $error');
    }

    developer.log(
      message,
      time: DateTime.now(),
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String tag, String message) {
    _record('INFO', tag, message);
  }

  static void warning(String tag, String message) {
    _record('WARN', tag, message);
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _record('ERROR', tag, message, error, stackTrace);
  }
}