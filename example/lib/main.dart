import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hybrid/flutter_hybrid.dart';

import 'app.dart';

void main() {
  HybridWidgetsBinding.ensureInitialized();
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    print(error);
  });
}
