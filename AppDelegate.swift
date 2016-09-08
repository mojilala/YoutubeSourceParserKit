//
//  AppDelegate.swift
//  youtube-parser
//
//  Created by Toygar Dündaralp on 7/5/15.
//  Copyright (c) 2015 Toygar Dündaralp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let testURL = URL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")!
    Youtube.h264videosWithYoutubeURL(testURL) { (videoInfo, error) -> Void in
      if let videoURLString = videoInfo?["url"] as? String,
        let videoTitle = videoInfo?["title"] as? String {
          print("\(videoTitle)")
          print("\(videoURLString)")
      }
    }
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) { }
  
  func applicationDidEnterBackground(_ application: UIApplication) { }
  
  func applicationWillEnterForeground(_ application: UIApplication) { }
  
  func applicationDidBecomeActive(_ application: UIApplication) { }
  
  func applicationWillTerminate(_ application: UIApplication) { }
}
