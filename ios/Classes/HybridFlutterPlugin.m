#import "HybridFlutterPlugin.h"
#import "HybridFlutterManager.h"

@interface HybridFlutterPlugin()

@property(nonatomic, strong) FlutterMethodChannel *navigationChannel;

@property(nonatomic, strong) FlutterBasicMessageChannel *lifecycleChannel;

@end

@implementation HybridFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  HybridFlutterPlugin* instance = [[HybridFlutterPlugin alloc] init];
  instance.lifecycleChannel = [FlutterBasicMessageChannel messageChannelWithName:@"hybrid/lifecycle"
                                                                 binaryMessenger:registrar.messenger
                                                                           codec:[FlutterStringCodec sharedInstance]];
  instance.navigationChannel = [FlutterMethodChannel methodChannelWithName:@"hybrid/navigation"
                                                           binaryMessenger:registrar.messenger];
  [registrar addMethodCallDelegate:instance channel:instance.navigationChannel];
  [registrar publish:instance];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  _lifecycleChannel = nil;
  _navigationChannel = nil;
}

+ (instancetype)fromEngine:(FlutterEngine *)engine {
  NSObject *plugin = [engine valuePublishedByPlugin: @"HybridFlutterPlugin"];
  if ([plugin isKindOfClass: [HybridFlutterPlugin class]]) {
    return (HybridFlutterPlugin *) plugin;
  }
  return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (![HybridFlutterManager sharedInstance].navigator) {
    result([FlutterError errorWithCode:@"no_navigator" message:@"navigator not provided" details:nil]);
    return;
  }
  if ([@"pop" isEqualToString:call.method]) {
    NSNumber *routeId = [call.arguments objectForKey:@"routeId"];
    FlutterViewController *viewController = [[HybridFlutterManager sharedInstance] getFlutterViewControllerWithRouteId:routeId];
    if (viewController) {
      [[HybridFlutterManager sharedInstance].navigator pop:viewController
                                                    result:[call.arguments objectForKey:@"result"]];
    }
  } else if ([@"push" isEqualToString:call.method]) {
    NSNumber *routeId = [call.arguments objectForKey:@"routeId"];
    FlutterViewController *viewController = [[HybridFlutterManager sharedInstance] getFlutterViewControllerWithRouteId:routeId];
    if (viewController) {
      [[HybridFlutterManager sharedInstance].navigator pushRoute:[call.arguments objectForKey:@"route"]
                                                       arguments:[call.arguments objectForKey:@"arguments"]
                                                  viewController:viewController];
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)sendLifecycleMessage:(id)message {
  if (_lifecycleChannel) {
    [_lifecycleChannel sendMessage:message];
  }
}

- (void)newRoute:(NSString *)route routeId:(NSNumber *)routeId {
  if (_navigationChannel) {
    [_navigationChannel invokeMethod:@"newRoute" arguments:@{
      @"routeId": routeId,
      @"route": route
    }];
  }
}

- (void)removeRoute:(NSNumber *)routeId {
  if (_navigationChannel) {
    [_navigationChannel invokeMethod:@"removeRoute" arguments:routeId];
  }
}

@end
