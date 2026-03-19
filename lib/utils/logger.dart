import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class Log {
  static void d(String tag, String message) {
    if (kDebugMode) {
      dev.log(message, name: tag);
    }
  }

  static void w(
    String tag,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    if (kDebugMode) {
      dev.log(
        '⚠️ $message',
        name: tag,
        level: 900,
        error: error,
        stackTrace: stack,
      );
    }
  }

  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    if (kDebugMode) {
      dev.log(
        '❌ $message',
        name: tag,
        level: 1000,
        error: error,
        stackTrace: stack,
      );
    }
  }
}
