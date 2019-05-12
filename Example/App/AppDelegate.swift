//
//  AppDelegate.swift
//  App
//
//  Created by Ben on 11/05/2019.
//  Copyright © 2019 bcylin. All rights reserved.
//

import UIKit
import CPDAcknowledgements

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.rootViewController = UINavigationController(rootViewController: CPDAcknowledgementsViewController())
    window?.makeKeyAndVisible()
    return true
  }

}
