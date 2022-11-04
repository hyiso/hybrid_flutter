import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'channels.dart';


class HybridWidgetsBinding extends BindingBase with GestureBinding, SchedulerBinding, ServicesBinding, PaintingBinding, SemanticsBinding, RendererBinding, WidgetsBinding {

  /// Returns an instance of the [WidgetsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [WidgetsFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [WidgetsBinding].
  ///
  /// You only need to call this method if you need the binding to be
  /// initialized before calling [runApp].
  ///
  /// In the `flutter_test` framework, [testWidgets] initializes the
  /// binding instance to a [TestWidgetsFlutterBinding], not a
  /// [WidgetsFlutterBinding].
  static WidgetsBinding ensureInitialized() {
    return HybridWidgetsBinding();
  }

  @override
  void initInstances() {
    super.initInstances();
    SystemChannels.lifecycle.setMessageHandler(null);
    HybridChannels.lifecycle.setMessageHandler(_handleHybridLifecycleMessage);
  }

  Future<String?> _handleHybridLifecycleMessage(String? message) async {
    debugPrint('_handleHybridLifecycleMessage: $message');
    handleAppLifecycleStateChanged(_parseHybridAppLifecycleMessage(message!)!);
    return null;
  }

  static AppLifecycleState? _parseHybridAppLifecycleMessage(String message) {
    switch (message) {
      case 'HybridAppLifecycleState.paused':
        return AppLifecycleState.paused;
      case 'HybridAppLifecycleState.resumed':
        return AppLifecycleState.resumed;
      case 'HybridAppLifecycleState.inactive':
        return AppLifecycleState.inactive;
      case 'HybridAppLifecycleState.detached':
        return AppLifecycleState.detached;
    }
    return null;
  }
}