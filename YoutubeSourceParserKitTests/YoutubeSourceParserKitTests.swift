//
//  youtube_parserTests.swift
//  youtube-parserTests
//
//  Created by Toygar Dündaralp on 7/5/15.
//  Copyright (c) 2015 Toygar Dündaralp. All rights reserved.
//

import UIKit
import XCTest

class YoutubeSourceParserKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

  func testStringByDecodingURLFormat() {
    let originalString = "https://www.youtube.com/watch?v=XUFpdwbfqqQ+XUFpdwbfqqQ"
    let testString = "https://www.youtube.com/watch?v=XUFpdwbfqqQ XUFpdwbfqqQ"
    let comparsionString = originalString.stringByDecodingURLFormat()
    XCTAssertNotNil(comparsionString, "comparsionString is nil")
    XCTAssertEqual(comparsionString, testString, "String decoding failed")
  }

  func testDictionaryFromQueryStringComponents() {
    let sampleLink = "https://www.youtube.com/watch?v=o0jJiB2Ygpg&list=RDo0jJiB2Ygpg"
    let dictionary = sampleLink.dictionaryFromQueryStringComponents() as [String:AnyObject]
    XCTAssertNotNil(dictionary["list"], "url dictionary parse error")
    if let list = dictionary["list"] as? String {
      XCTAssertEqual(list, "RDo0jJiB2Ygpg", "list not equal value")
    }
    if let link = dictionary["https://www.youtube.com/watch?v="] as? String {
      XCTAssertEqual(link, "o0jJiB2Ygpg", "link not equal value")
    }
  }

  func testInvalidURLs1() {
    let sampleLink = NSURL(string: "?v=1hZ98an9wjo")!
    XCTAssertNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is not nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "1hZ98an9wjo", "Youtube ID not same")
    }
  }

  func testInvalidURLs2() {
    let sampleLink = NSURL(string: "?v=")!
    XCTAssertNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is not nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "", "Youtube ID not same")
    }
  }

  func testInvalidURLs3() {
    let sampleLink = NSURL(string: "v=1hZ98an9wjo")!
    XCTAssertNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is not nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "v=1hZ98an9wjo", "Youtube ID not same")
    }
  }

  func testInvalidURLs4() {
    let sampleLink = NSURL(string: "v1hZ98an9wjo")!
    XCTAssertNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is not nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "v1hZ98an9wjo", "Youtube ID not same")
    }
  }

  func testYoutubeIDFromYoutubeURL() {
    let sampleLink = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo")!
    XCTAssertNotNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "1hZ98an9wjo", "Youtube ID not same")
    }
  }

  func testYoutubeIDFromMobileYoutubeURL() {
    let sampleLink = NSURL(string: "https://m.youtube.com/#/watch?v=1hZ98an9wjo")!
    XCTAssertNotNil(Youtube.youtubeIDFromYoutubeURL(sampleLink), "Youtube ID is nil")
    if let youtubeID = Youtube.youtubeIDFromYoutubeURL(sampleLink) {
      XCTAssertEqual(youtubeID, "1hZ98an9wjo", "Youtube ID not same")
    }
  }

  func testH264videosWithYoutubeURL() {
    if let videoComponents = Youtube.h264videosWithYoutubeID("1hZ98an9wjo") {
      XCTAssertNotNil(videoComponents, "video component is nil")
      if let itag = videoComponents["itag"] as? String {
        XCTAssertEqual(itag, "22", "itag not equal")
      }
      if let quality = videoComponents["quality"] as? String {
        XCTAssertEqual(quality, "hd720", "quality not equal")
      }
      if let fallback_host = videoComponents["fallback_host"] as? String {
        XCTAssertEqual(fallback_host, "tc.v7.cache1.googlevideo.com", "fallback_host not equal")
      }
      if let type = videoComponents["type"] as? String {
        XCTAssertEqual(type, "video/mp4; codecs=\"avc1.64001F, mp4a.40.2\"", "type not equal")
      }
    }
  }

  func testVideoQuality(){
    if let videoURL = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo") {
      Youtube.h264videosWithYoutubeURL(videoURL, completion: { (videoInfo, error) -> Void in
        XCTAssertNotNil(videoInfo, "video dictionary is nil")
        if let info = videoInfo as [String:AnyObject]? {
          if let quality = info["quality"] as? String {
            XCTAssertEqual(quality, "hd720", "quality not equal")
          }
        }
      })
    }
  }

  func testItagControl(){
    if let videoURL = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo") {
      Youtube.h264videosWithYoutubeURL(videoURL, completion: { (videoInfo, error) -> Void in
        XCTAssertNotNil(videoInfo, "video dictionary is nil")
        if let info = videoInfo as [String:AnyObject]? {
          if let itag = info["itag"] as? String {
            XCTAssertEqual(itag, "22", "itag not equal")
          }
        }
      })
    }
  }

  func testVideoTypeControl(){
    if let videoURL = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo") {
      Youtube.h264videosWithYoutubeURL(videoURL, completion: { (videoInfo, error) -> Void in
        XCTAssertNotNil(videoInfo, "video dictionary is nil")
        if let info = videoInfo as [String:AnyObject]? {
          if let type = info["type"] as? String {
            XCTAssertEqual(type, "video/mp4; codecs=\"avc1.64001F, mp4a.40.2\"", "type not equal")
          }
        }
      })
    }
  }

  func testFallbackHostControl(){
    if let videoURL = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo") {
      Youtube.h264videosWithYoutubeURL(videoURL, completion: { (videoInfo, error) -> Void in
        XCTAssertNotNil(videoInfo, "video dictionary is nil")
        if let info = videoInfo as [String:AnyObject]? {
          if let fallback_host = info["fallback_host"] as? String {
            XCTAssertEqual(fallback_host, "tc.v7.cache1.googlevideo.com", "fallback_host not equal")
          }
        }
      })
    }
  }

  func testIsLiveVideoTest() {
    if let liveVideoURL = NSURL(string: "https://www.youtube.com/watch?v=rxGoGg7n77A"){
      Youtube.h264videosWithYoutubeURL(liveVideoURL, completion: { (videoInfo, error) -> Void in
        XCTAssertNotNil(videoInfo, "video dictionary is nil")
        if let info = videoInfo as [String:AnyObject]? {
          XCTAssertNotNil(info["url"], "live stream url is nil")
        }
      })
    }
  }

  func testInfoUrl(){
    XCTAssertEqual(Youtube.infoURL, "http://www.youtube.com/get_video_info?video_id=", "Info url not correct!")
  }

  func testUserAgent() {
     XCTAssertEqual(Youtube.userAgent, "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4", "User Agent not correct!")
  }

  func testH264videosWithYoutubeURLBlock(){
    let expectation: XCTestExpectation = self.expectationWithDescription("Handler called")
    if let videoURL = NSURL(string: "http://www.youtube.com/watch?v=1hZ98an9wjo") {
      Youtube.h264videosWithYoutubeURL(videoURL, completion: { (videoInfo, error) -> Void in
        expectation.fulfill()
        if let info = videoInfo as [String:AnyObject]? {
          if let quality = info["itag"] as? String {
            XCTAssertEqual(quality, "22", "itag not equal")
          }
        }
      })
      self.waitForExpectationsWithTimeout(2, handler: nil)
    }

  }
  
}
