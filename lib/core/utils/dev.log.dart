import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

void devLog(
  String message, {
  String name = 'PassPoint',
  Map<String, dynamic>? params,
}) {
  if (kDebugMode) {
    developer.log(
      message,
      name: name,
      error: null,
      stackTrace: null,
      time: DateTime.now(),
      level: 0,
    );
    if (params != null && params.isNotEmpty) {
      developer.log('params:$params', name: name);
    }
  }
}
