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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let testURL = NSURL(string: "https://www.youtube.com/watch?v=_SCdj9d8SUQ&list=RD_SCdj9d8SUQ&start_radio=1")!
    Youtube.h264videosWithYoutubeURL(youtubeURL: testURL) { (videoInfo, error) -> Void in
      if let videoURLString = videoInfo?["url"] as? String,
        let videoTitle = videoInfo?["title"] as? String {
          print("\(videoTitle)")
          print("\(videoURLString)")
        URLSession.shared.dataTask(with: URL(string: videoURLString)!, completionHandler: { (data, response, error) in
            if let data = data {
                print(data.count)
            }
        }).resume()
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
