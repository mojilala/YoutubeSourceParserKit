# youtube-parser
[![Build Status](https://travis-ci.org/toygard/youtube-parser.svg?branch=master)](https://travis-ci.org/toygard/youtube-parser) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/isair/JSONHelper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

YouTube link parser for swift

##Introduction

__Requires iOS 7 or later and Xcode 6.1+__

##Installation

###[Cocoapods](https://github.com/CocoaPods/CocoaPods)

To install via CocoaPods add this line to your `Podfile`.

```
use_frameworks!

pod "youtube-parser"
```

Then, run the following command:

```$ pod install```

##Usage

```swift
import youtube_parser
```

```swift
let testURL = NSURL(string: "https://www.youtube.com/watch?v=ngElkyQ6Rhs")!
    Youtube.h264videosWithYoutubeURL(testURL,
      completion: { (videoInfo, error) -> Void in
        if let
          videoURLString = videoInfo?["url"] as? String,
          videoTitle = videoInfo?["title"] as? String {
            println("\(videoTitle)")
            println("\(videoURLString)")
        }
    })
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
