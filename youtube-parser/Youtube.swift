//
//  Youtube.swift
//  youtube-parser
//
//  Created by Toygar Dündaralp on 7/5/15.
//  Copyright (c) 2015 Toygar Dündaralp. All rights reserved.
//

import UIKit

public extension NSURL {
  /**
  Parses a query string of an NSURL

  @return key value dictionary with each parameter as an array
  */
  func dictionaryForQueryString() -> [String: AnyObject]? {
    if let query = self.query {
      return query.dictionaryFromQueryStringComponents()
    }

    // Note: find youtube ID in m.youtube.com "https://m.youtube.com/#/watch?v=1hZ98an9wjo"
    let result = absoluteString.componentsSeparatedByString("?")
    if result.count > 1 {
      return result.last?.dictionaryFromQueryStringComponents()
    }
    return nil
  }
}

public extension NSString {
  /**
  Convenient method for decoding a html encoded string
  */
  func stringByDecodingURLFormat() -> String {
    let result = self.stringByReplacingOccurrencesOfString("+", withString:" ")
    return result.stringByRemovingPercentEncoding!
  }

  /**
  Parses a query string

  @return key value dictionary with each parameter as an array
  */
  func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
    var parameters = [String: AnyObject]()
    for keyValue in componentsSeparatedByString("&") {
      let keyValueArray = keyValue.componentsSeparatedByString("=")
      if keyValueArray.count < 2 {
        continue
      }
      let key = keyValueArray[0].stringByDecodingURLFormat()
      let value = keyValueArray[1].stringByDecodingURLFormat()
      parameters[key] = value
    }
    return parameters
  }
}

public class Youtube: NSObject {
  static let infoURL = "http://www.youtube.com/get_video_info?video_id="
  static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
  /**
  Method for retrieving the youtube ID from a youtube URL

  @param youtubeURL the the complete youtube video url, either youtu.be or youtube.com
  @return string with desired youtube id
  */
  public static func youtubeIDFromYoutubeURL(youtubeURL: NSURL) -> String? {
    if let
      youtubeHost = youtubeURL.host,
      youtubePathComponents = youtubeURL.pathComponents {
        let youtubeAbsoluteString = youtubeURL.absoluteString
        if youtubeHost == "youtu.be" as String? {
          return youtubePathComponents[1]
        } else if youtubeAbsoluteString.rangeOfString("www.youtube.com/embed") != nil {
          return youtubePathComponents[2]
        } else if youtubeHost == "youtube.googleapis.com" ||
          youtubeURL.pathComponents!.first == "www.youtube.com" as String? {
            return youtubePathComponents[2]
        } else if let
          queryString = youtubeURL.dictionaryForQueryString(),
          searchParam = queryString["v"] as? String {
            return searchParam
        }
    }
    return nil
  }
  /**
  Method for retreiving a iOS supported video link

  @param youtubeURL the the complete youtube video url
  @return dictionary with the available formats for the selected video
  
  */
  public static func h264videosWithYoutubeID(youtubeID: String) -> [String: AnyObject]? {
    let urlString = String(format: "%@%@", infoURL, youtubeID) as String
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    request.timeoutInterval = 5.0
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.HTTPMethod = "GET"
    var responseString = NSString()
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let group = dispatch_group_create()
    dispatch_group_enter(group)
    session.dataTaskWithRequest(request, completionHandler: { (data, response, _) -> Void in
      if let data = data as NSData? {
        responseString = NSString(data: data, encoding: NSUTF8StringEncoding)!
      }
      dispatch_group_leave(group)
    }).resume()
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    let parts = responseString.dictionaryFromQueryStringComponents()
    if parts.count > 0 {
      var videoTitle: String = ""
      var streamImage: String = ""
      if let title = parts["title"] as? String {
        videoTitle = title
      }
      if let image = parts["iurl"] as? String {
        streamImage = image
      }
      if let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String {
        // Live Stream
        if let _: AnyObject = parts["live_playback"]{
          if let hlsvp = parts["hlsvp"] as? String {
            return [
              "url": "\(hlsvp)",
              "title": "\(videoTitle)",
              "image": "\(streamImage)",
              "isStream": true
            ]
          }
        } else {
          let fmtStreamMapArray = fmtStreamMap.componentsSeparatedByString(",")
          for videoEncodedString in fmtStreamMapArray {
            var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
            videoComponents["title"] = videoTitle
            videoComponents["isStream"] = false
            return videoComponents as [String: AnyObject]
          }
        }
      }
    }
    return nil
  }
  
  /**
  Block based method for retreiving a iOS supported video link

  @param youtubeURL the the complete youtube video url
  @param completeBlock the block which is called on completion

  */
  public static func h264videosWithYoutubeURL(youtubeURL: NSURL,completion: ((
    videoInfo: [String: AnyObject]?, error: NSError?) -> Void)?) {
      let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
      dispatch_async(dispatch_get_global_queue(priority, 0)) {
        if let youtubeID = self.youtubeIDFromYoutubeURL(youtubeURL), videoInformation = self.h264videosWithYoutubeID(youtubeID) {
          dispatch_async(dispatch_get_main_queue()) {
            completion?(videoInfo: videoInformation, error: nil)
          }
        }else{
          dispatch_async(dispatch_get_main_queue()) {
            completion?(videoInfo: nil, error: NSError(domain: "com.player.youtube.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
          }
        }
      }
    }
  }
