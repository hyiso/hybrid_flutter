#import <Flutter/Flutter.h>
#import "FlutterHybridManager.h"
#import "FlutterHybridPlugin.h"

@interface FlutterHybridManager()

@property(nonatomic) int shareCount;

@property(nonatomic) int spawnCount;

@property(nonatomic) int uniqueRouteId;

@property(nonatomic, strong) FlutterEngine *rootEngine;

@property(nonatomic, strong) FlutterEngineGroup *engineGroup;

@property(nonatomic, strong) NSMutableDictionary<NSNumber*, NSValue*> *viewControllers;

// 是否引擎预热
@property(nonatomic) BOOL isPreload;

@end

NSString* const FlutterEngineWillDealloc = @"FlutterEngineWillDealloc";

@implementation FlutterHybridManager

+ (instancetype)sharedInstance {
  static FlutterHybridManager *_instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [self.class new];
    _instance.viewControllers = [[NSMutableDictionary alloc] init];
  });
  return _instance;
}

- (void)preloadEngine:(nullable FlutterDartProject *)project {
  if (!_isPreload) {
    _isPreload = YES;
    [self createRootEngine:project];
  }
}

- (void)releasePreload {
  if (_isPreload) {
    _isPreload = NO;
    [self releaseRootEngine];
  }
}

- (void)createRootEngine:(nullable FlutterDartProject *)project {
  if (!_engineGroup) {
    _engineGroup = [[FlutterEngineGroup alloc] initWithName:@"io.flutter" project:project];
  }
  if (!_rootEngine) {
    ++_spawnCount;
    _rootEngine = [_engineGroup makeEngineWithEntrypoint:nil libraryURI:nil];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onEngineWillBeDealloced:)
                   name:FlutterEngineWillDealloc
                 object:_rootEngine];
  }
}

- (void)onEngineWillBeDealloced:(NSNotification*)notification {
  if (notification.object && [notification.object isKindOfClass:[FlutterEngine class]]) {
    [notification.object destroyContext];
    [[NSNotificationCenter defaultCenter] removeObserver:_engineGroup
                                                    name:FlutterEngineWillDealloc
                                                  object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FlutterEngineWillDealloc
                                                  object:notification.object];
  }
  --_spawnCount;
  if (_spawnCount < 0) {
    _spawnCount = 0;
  }
  if (_spawnCount == 1) {
    [self releaseRootEngine];
  }
  if (_spawnCount == 0) {
    _engineGroup = nil;
  }
}

- (void)releaseRootEngine {
  if (_isPreload) {
    return;
  }
  // 还有使用引擎的地方
  if (_shareCount > 0 || _spawnCount > 1) {
    return;
  }
  _rootEngine = nil;
}

- (FlutterEngine *)shareEngine:(nullable FlutterDartProject *)project {
  [self createRootEngine:project];
  ++_shareCount;
  return _rootEngine;
}

- (void)releaseShareEngine {
  --_shareCount;
  if (_shareCount < 0) {
    _shareCount = 0;
  }
  if (_shareCount == 0) {
    [self releaseRootEngine];
  }
}

/**
 * 多引擎使用 FlutterEngineGroup 来创建引擎
 */
- (FlutterEngine *)spawnEngine:(nullable FlutterDartProject *)project {
  // 2.10.3 版本由于销毁了第一个引擎后，同时由第一个引擎创建的后续引擎 image decoder registry 会丢失
  // issue：https://github.com/flutter/flutter/issues/98013
  // 为了规避这个 bug，不使用第一个引擎，只使用 spawn 的引擎
  [self createRootEngine:project];
  ++_spawnCount;
  FlutterEngine *engine = [_engineGroup makeEngineWithEntrypoint:nil libraryURI:nil];
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(onEngineWillBeDealloced:)
                 name:FlutterEngineWillDealloc
               object:engine];
  return engine;
}

- (int)newRoute:(NSString *)route flutterViewController:(FlutterViewController *)flutterViewController {
  int routeId = ++_uniqueRouteId;
  [[FlutterHybridPlugin fromEngine:flutterViewController.engine] newRoute:route routeId:@(routeId)];
  [_viewControllers setObject:[NSValue valueWithNonretainedObject: flutterViewController] forKey:@(routeId)];
  return routeId;
}

-(FlutterViewController *)getFlutterViewControllerWithRouteId:(NSNumber*)routeId {
  NSValue *value = [_viewControllers objectForKey: routeId];
  return [value nonretainedObjectValue];
}

- (void)removeRoute:(NSNumber *)routeId {
  FlutterViewController *flutterViewController = [self getFlutterViewControllerWithRouteId:routeId];
  [[FlutterHybridPlugin fromEngine:flutterViewController.engine] removeRoute:routeId];
  [_viewControllers removeObjectForKey:routeId];
}

@end
