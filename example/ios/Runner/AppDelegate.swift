import UIKit
import Flutter
import flutter_hybrid

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let win = UIWindow.init(frame: UIScreen.main.bounds)
    let flutterViewController = MyFlutterViewController.init(route: "/home", parameters: nil, useNewEngine: false)
    let navigationController = UINavigationController.init(rootViewController: flutterViewController)
    navigationController.navigationBar.isHidden = true
    win.rootViewController = navigationController
    self.window = win
    self.window.makeKeyAndVisible()
    FlutterHybridManager.sharedInstance().navigator = MyFlutterHybridNavigator.init()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
