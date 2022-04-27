#import <Flutter/Flutter.h>

@interface HybridFlutterViewController : FlutterViewController

-(BOOL)shouldUseNewEngine;

-(BOOL)shouldSnapshotForLeaving;

@end
