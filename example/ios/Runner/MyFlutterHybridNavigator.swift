import Foundation
import hybrid_flutter

class MyFlutterHybridNavigator : NSObject, FlutterHybridNavigator {
  func pushRoute(_ route: String?, arguments: Any?, viewController flutterViewController: FlutterViewController?) {
    var useNewEngine = false
    if (arguments != nil && arguments is [String:String]) {
      useNewEngine = (arguments as! [String:String])["useNewEngine"] == "1"
    }
    let vc = MyFlutterViewController.init(route: route, parameters: arguments as? [String:String], useNewEngine: useNewEngine)
    flutterViewController?.navigationController?.pushViewController(vc, animated: true)
  }
  
  func pop(_ flutterViewController: FlutterViewController?, result: Any?) {
    flutterViewController?.navigationController?.popViewController(animated: true)
  }
}
