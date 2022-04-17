#ifndef FlutterHybridNavigator_h
#define FlutterHybridNavigator_h

@protocol FlutterHybridNavigator <NSObject>

-(void)pushRoute:(NSString * _Nullable)route
       arguments:(id _Nullable)arguments
  viewController:(FlutterViewController * _Nullable)flutterViewController;

-(void)pop:(FlutterViewController * _Nullable)flutterViewController result:(id _Nullable )result;

@end

#endif /* FlutterHybridNavigator_h */
