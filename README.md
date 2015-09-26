# youtube-parser
[![Build Status](https://travis-ci.org/toygard/youtube-parser.svg?branch=master)](https://travis-ci.org/toygard/youtube-parser) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/toygard/youtube-parser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) ![Gitter](https://img.shields.io/badge/license-MIT-blue.svg)

YouTube Video Link Parser for Swift

##Introduction

__Requires iOS 8 or later and Xcode 7.0+__<br/>
Swift support uses dynamic frameworks and is therefore only supported on iOS > 8.

##Installation

To install via CocoaPods add this line to your `Podfile`.
```
use_frameworks!
```
and
```
pod "youtube-parser"
```

Then, run the following command:

```$ pod install```

##Usage

```swift
import youtube_parser
```

```swift
let testURL = NSURL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")!
    Youtube.h264videosWithYoutubeURL(testURL) { (videoInfo, error) -> Void in
      if let videoURLString = videoInfo?["url"] as? String,
        videoTitle = videoInfo?["title"] as? String {
          print("\(videoTitle)")
          print("\(videoURLString)")
      }
    }
```

```
videoInfo output:
```
```json
{
    "title": "[Video Title]",
    "isStream": 0,
    "quality": "hd720",
    "itag": 22,
    "fallback_host": "tc.v20.cache2.googlevideo.com",
    "url": "http://[Source URL]"
}
```

##MPMoviePlayerController Usage

![alt tag](http://s10.postimg.org/5j1mristl/i_OS_Simulator_Screen_Shot_Jul_12_2015_14_33_02.png)

```swift
import UIKit
import youtube_parser
import MediaPlayer

class ViewController: UIViewController {

  let moviePlayer = MPMoviePlayerController()

  override func viewDidLoad() {
    super.viewDidLoad()
    moviePlayer.view.frame = view.frame
    view.addSubview(moviePlayer.view)
    moviePlayer.fullscreen = true
    let youtubeURL = NSURL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")!
    playVideoWithYoutubeURL(youtubeURL)
  }

  func playVideoWithYoutubeURL(url: NSURL) {
    Youtube.h264videosWithYoutubeURL(url, completion: { (videoInfo, error) -> Void in
      if let
        videoURLString = videoInfo?["url"] as? String,
        videoTitle = videoInfo?["title"] as? String {
          self.moviePlayer.contentURL = NSURL(string: videoURLString)
      }
    })
  }
}
```
