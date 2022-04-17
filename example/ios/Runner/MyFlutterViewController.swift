import Foundation
import hybrid_flutter

class MyFlutterViewController : FlutterHybridViewController {
  
  override func shouldUseNewEngine() -> Bool {
    return useNewEngine
  }
  
  static var shareCount:Int = 0
  static var spawnCount:Int = 0
  
  private var useNewEngine:Bool
  
  init(route:String?, parameters: [String:String]?, useNewEngine: Bool) {
    let initialRoute = MyFlutterViewController.buildInitialRoute(route: route, parameters: parameters, useNewEngine: useNewEngine)
    self.useNewEngine = useNewEngine
    super.init(project: nil, initialRoute: initialRoute, nibName: nil, bundle: nil)
    if (!self.engine!.hasPlugin("FlutterHybridPlugin")) {
      GeneratedPluginRegistrant.register(with: self.engine!)
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func buildInitialRoute(route:String?, parameters:[String:String]?, useNewEngine:Bool) -> String? {
    if (route == nil) {
      return nil
    }
    var index:Int = 0
    if (useNewEngine) {
      spawnCount += 1
      index = spawnCount
    } else {
      shareCount += 1
      index = shareCount
    }
    var dict:[String:String] = [
      "index":String(index)
    ];
    if (parameters != nil && !parameters!.isEmpty) {
      dict.merge(parameters!, uniquingKeysWith: { (_, last) in last })
    }
    var initialRoute:String = route!
    if (!dict.isEmpty) {
      initialRoute.append("?")
      var querys:[String] = []
      dict.forEach { (key: String, value: String) in
        querys.append(String(format: "%@=%@", key, value))
      }
      initialRoute.append(querys.joined(separator: "&"))
    }
    return initialRoute.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
  }
}
