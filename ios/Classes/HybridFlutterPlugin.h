#import <Flutter/Flutter.h>

@interface HybridFlutterPlugin : NSObject<FlutterPlugin>

+(instancetype)fromEngine:(FlutterEngine *)engine;

-(void)sendLifecycleMessage:(id _Nullable)message;

-(void)newRoute:(NSString *)route routeId:(NSNumber *)routeId;

-(void)removeRoute:(NSNumber*)routeId;

@end
