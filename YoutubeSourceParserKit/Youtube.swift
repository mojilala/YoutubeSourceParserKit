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
    
    if let result = absoluteString?.components(separatedBy: "?"), result.count > 1 {
      return result.last?.dictionaryFromQueryStringComponents()
    }
    return nil
  }
}

public extension NSString {
  /**
  Convenient method for decoding a html encoded string
  */
  func stringByDecodingURLFormat() -> String? {
    let result = self.replacingOccurrences(of: "+", with:" ")
    return result.removingPercentEncoding
  }

  /**
  Parses a query string

  @return key value dictionary with each parameter as an array
  */
  func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
    var parameters = [String: AnyObject]()
    for keyValue in components(separatedBy: "&") {
        let keyValueArray = keyValue.components(separatedBy: "=")
      if keyValueArray.count < 2 {
        continue
      }
      let key = keyValueArray[0].stringByDecodingURLFormat()
      let value = keyValueArray[1].stringByDecodingURLFormat()
        parameters[key!] = value as AnyObject
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
        let youtubePathComponents = youtubeURL.pathComponents {
        let youtubeAbsoluteString = youtubeURL.absoluteString
        if youtubeHost == "youtu.be" as String? {
          return youtubePathComponents[1]
        } else if youtubeAbsoluteString?.range(of:"www.youtube.com/embed") != nil {
          return youtubePathComponents[2]
        } else if youtubeHost == "youtube.googleapis.com" ||
          youtubeURL.pathComponents!.first == "www.youtube.com" as String? {
            return youtubePathComponents[2]
        } else if let
          queryString = youtubeURL.dictionaryForQueryString(),
            let searchParam = queryString["v"] as? String {
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
    let request = NSMutableURLRequest(url: url as URL)
    request.timeoutInterval = 5.0
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.httpMethod = "GET"
    var responseString = NSString()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let group = DispatchGroup()
    group.enter()
    session.dataTask(with: request as URLRequest, completionHandler: { (data, response, _) -> Void in
      if let data = data as NSData? {
        responseString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!
      }
        group.leave()
    }).resume()
    let _ = group.wait(timeout: .distantFuture)
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
                "url": "\(hlsvp)" as AnyObject,
                "title": "\(videoTitle)" as AnyObject,
                "image": "\(streamImage)" as AnyObject,
                "isStream": true as AnyObject
            ]
          }
        } else {
            let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")
          for videoEncodedString in fmtStreamMapArray {
            var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
            videoComponents["title"] = videoTitle as AnyObject
            videoComponents["isStream"] = false as AnyObject
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
        _ videoInfo: [String: AnyObject]?, _ error: NSError?) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            if let youtubeID = self.youtubeIDFromYoutubeURL(youtubeURL: youtubeURL), let videoInformation = self.h264videosWithYoutubeID(youtubeID: youtubeID) {
                DispatchQueue.main.async {
                    completion?(videoInformation, nil)
                }
            }else{
                DispatchQueue.main.async {
                    completion?(nil, NSError(domain: "com.player.youtube.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
                }
            }
        }
    }
}
