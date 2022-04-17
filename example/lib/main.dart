import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hybrid_flutter/hybrid_flutter.dart';

import 'app.dart';

void main() {
  HybridWidgetsBinding.ensureInitialized();
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    print(error);
  });
}
