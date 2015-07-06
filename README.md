# youtube-parser
YouTube link parser for swift

##Introduction

__Requires iOS 7 or later and Xcode 6.1+__

##Installation

###[Cocoapods](https://github.com/CocoaPods/CocoaPods)

Add the following line in your `Podfile`.

```
pod "youtube-parser"
```

##Basic Tutorial

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
