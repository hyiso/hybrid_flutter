#import "HybridFlutterViewController.h"
#import "HybridFlutterManager.h"
#import "HybridFlutterPlugin.h"

@interface HybridFlutterViewController ()

@property(nonatomic) int routeId;

@property(nonatomic, strong) NSString *initialRoute;

@end

@implementation HybridFlutterViewController

- (instancetype)initWithProject:(nullable FlutterDartProject *)project
                   initialRoute:(NSString *)initialRoute
                        nibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle {
  FlutterEngine *engine;
  _initialRoute = initialRoute;
  if (self.shouldUseNewEngine) {
    engine = [[HybridFlutterManager sharedInstance] spawnEngine:project];
  } else {
    engine = [[HybridFlutterManager sharedInstance] shareEngine:project];
  }
  return [super initWithEngine:engine nibName:nibName bundle:nibBundle];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (_initialRoute && ![@"/" isEqualToString:_initialRoute]) {
    _routeId = [[HybridFlutterManager sharedInstance] newRoute:_initialRoute flutterViewController:self];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [self updateHybridAppLifecycleState:@"HybridAppLifecycleState.inactive"];
  [self attachFlutterEngine];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
    [self updateHybridAppLifecycleState:@"HybridAppLifecycleState.resumed"];
  }
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self updateHybridAppLifecycleState:@"HybridAppLifecycleState.inactive"];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self updateHybridAppLifecycleState:@"HybridAppLifecycleState.paused"];
  [super viewDidDisappear:animated];
}

- (void)attachFlutterEngine {
  if (self.engine.viewController != self) {
    self.engine.viewController = self;
  }
}

// See https://github.com/flutter/engine/blob/75bef9f6c8ac2ed4e1e04cdfcd88b177d9f1850d/shell/platform/darwin/ios/framework/Source/FlutterViewController.mm#L690-L722
// This will be called at application lifecycle with one of
// AppLifecycleState.resumed
// AppLifecycleState.inactive
// AppLifecycleState.paused
- (void)goToApplicationLifecycle:(nonnull NSString*)state {
  [self updateHybridAppLifecycleState:[NSString stringWithFormat:@"Hybrid%@", state]];
}

- (void)updateHybridAppLifecycleState:(nonnull NSString*)state {
  if (self.engine.viewController != self) {
    return;
  }
  HybridFlutterPlugin *plugin = [HybridFlutterPlugin fromEngine:self.engine];
  if (plugin) {
    [plugin sendLifecycleMessage:state];
  }
}

- (void)dealloc {
  [[HybridFlutterManager sharedInstance] removeRoute:@(self.routeId)];
  if (!self.shouldUseNewEngine) {
    [[HybridFlutterManager sharedInstance] releaseShareEngine];
  }
}

- (BOOL)shouldUseNewEngine {
  return NO;
}

@end
