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
  func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let testURL = NSURL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")!
    Youtube.h264videosWithYoutubeURL(testURL) { (videoInfo, error) -> Void in
      if let videoURLString = videoInfo?["url"] as? String,
        videoTitle = videoInfo?["title"] as? String {
          print("\(videoTitle)")
          print("\(videoURLString)")
      }
    }
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) { }
  
  func applicationDidEnterBackground(application: UIApplication) { }
  
  func applicationWillEnterForeground(application: UIApplication) { }
  
  func applicationDidBecomeActive(application: UIApplication) { }
  
  func applicationWillTerminate(application: UIApplication) { }
}
