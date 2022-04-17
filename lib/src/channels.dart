import 'package:flutter/services.dart';

class HybridChannels {

  static const MethodChannel navigation = OptionalMethodChannel('hybrid/navigation');


  /// A string [BasicMessageChannel] for lifecycle events.
  ///
  /// Valid messages are string representations of the values of the
  /// [AppLifecycleState] enumeration. A handler can be registered using
  /// [BasicMessageChannel.setMessageHandler].
  ///
  /// See also:
  ///
  ///  * [WidgetsBindingObserver.didChangeAppLifecycleState], which triggers
  ///    whenever a message is received on this channel.
  static const BasicMessageChannel<String?> lifecycle = BasicMessageChannel<String?>(
      'hybrid/lifecycle',
      StringCodec(),
  );
  
}