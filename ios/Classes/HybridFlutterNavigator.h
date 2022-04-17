#ifndef HybridFlutterNavigator_h
#define HybridFlutterNavigator_h

@protocol HybridFlutterNavigator <NSObject>

-(void)pushRoute:(NSString * _Nullable)route
       arguments:(id _Nullable)arguments
  viewController:(FlutterViewController * _Nullable)flutterViewController;

-(void)pop:(FlutterViewController * _Nullable)flutterViewController result:(id _Nullable )result;

@end

#endif /* HybridFlutterNavigator_h */
