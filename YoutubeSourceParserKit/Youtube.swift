//
//  Youtube.swift
//  youtube-parser
//
//  Created by Toygar Dündaralp on 7/5/15.
//  Copyright (c) 2015 Toygar Dündaralp. All rights reserved.
//

import Foundation

public extension URL {
    /**
     Parses a query string of an NSURL
     
     @return key value dictionary with each parameter as an array
     */
    func dictionaryForQueryString() -> [String: Any]? {
        if let query = self.query {
            return query.dictionaryFromQueryStringComponents()
        }
        
        // Note: find youtube ID in m.youtube.com "https://m.youtube.com/#/watch?v=1hZ98an9wjo"
        let result = absoluteString.components(separatedBy: "?")
        if result.count > 1 {
            return result.last?.dictionaryFromQueryStringComponents()
        }
        return nil
    }
}

public extension String {
    /**
     Convenient method for decoding a html encoded string
     */
    func stringByDecodingURLFormat() -> String {
        let result = self.replacingOccurrences(of: "+", with:" ")
        return result.removingPercentEncoding!
    }
    
    /**
     Parses a query string
     
     @return key value dictionary with each parameter as an array
     */
    func dictionaryFromQueryStringComponents() -> [String: Any] {
        var parameters = [String: Any]()
        for keyValue in components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            let key = keyValueArray[0].stringByDecodingURLFormat()
            let value = keyValueArray[1].stringByDecodingURLFormat()
            parameters[key] = value as Any?
        }
        return parameters
    }
}

open class Youtube: NSObject {
    static let infoURL = "http://www.youtube.com/get_video_info?video_id="
    static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    /**
     Method for retrieving the youtube ID from a youtube URL
     
     @param youtubeURL the the complete youtube video url, either youtu.be or youtube.com
     @return string with desired youtube id
     */
    open static func youtubeIDFromYoutubeURL(_ youtubeURL: URL) -> String? {
        guard let youtubeHost = youtubeURL.host else {
            return nil
        }
        
        let youtubePathComponents = youtubeURL.pathComponents
        let youtubeAbsoluteString = youtubeURL.absoluteString
        if youtubeHost == "youtu.be" as String? {
            return youtubePathComponents[1]
        } else if youtubeAbsoluteString.range(of: "www.youtube.com/embed") != nil {
            return youtubePathComponents[2]
        } else if youtubeHost == "youtube.googleapis.com" ||
            youtubeURL.pathComponents.first == "www.youtube.com" as String? {
            return youtubePathComponents[2]
        } else if let
            queryString = youtubeURL.dictionaryForQueryString(),
            let searchParam = queryString["v"] as? String {
            return searchParam
        }
        
        return nil
        
    }
    /**
     Method for retreiving a iOS supported video link
     
     @param youtubeURL the the complete youtube video url
     @return dictionary with the available formats for the selected video
     
     */
    open static func h264videosWithYoutubeID(_ youtubeID: String) -> [String: Any]? {
        guard let parts = loadVideoInfos(youtubeID: youtubeID), parts.count > 0 else {
            return nil
        }
        
        let videoTitle = parts["title"] as? String ?? ""
        let streamImage = parts["iurl"] as? String ?? ""
        
        guard let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String else {
            return nil
        }
        // Live Stream
        if parts["live_playback"] != nil {
            if let hlsvp = parts["hlsvp"] as? String {
                return [
                    "url": "\(hlsvp)" as Any,
                    "title": "\(videoTitle)" as Any,
                    "image": "\(streamImage)" as Any,
                    "isStream": true as Any
                ]
            }
        } else {
            let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")
            for videoEncodedString in fmtStreamMapArray {
                var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
                videoComponents["title"] = videoTitle as Any?
                videoComponents["isStream"] = false as Any?
                return videoComponents as [String: Any]
            }
        }
        
        return nil
    }
    
    private static func loadVideoInfos(youtubeID: String) -> [String: Any]? {
        
        var result: [String: Any]?
        let urlString = String(format: "%@%@", infoURL, youtubeID)
        
        guard let url = URL(string: urlString) else {
            return result
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let group = DispatchGroup()
        group.enter()
        session.dataTask(with: request, completionHandler: { (data, response, _) -> Void in
            if let data = data as Data?,
                let resultString = String(data: data, encoding: String.Encoding.utf8) {
                
                    result = resultString.dictionaryFromQueryStringComponents()
                
            }
            group.leave()
        }).resume()
        _ = group.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    /**
     Block based method for retreiving a iOS supported video link
     
     @param youtubeURL the the complete youtube video url
     @param completeBlock the block which is called on completion
     
     */
    open static func h264videosWithYoutubeURL(_ youtubeURL: URL,completion: ((
        _ videoInfo: [String: Any]?, _ error: NSError?) -> Void)?) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            if let youtubeID = self.youtubeIDFromYoutubeURL(youtubeURL), let videoInformation = self.h264videosWithYoutubeID(youtubeID) {
                DispatchQueue.main.async {
                    completion?(videoInformation, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion?(nil, NSError(domain: "com.player.youtube.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
                }
            }
        }
    }
}
