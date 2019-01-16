//
//  ViewController.swift
//  YoutubeSourceParserKit
//
//  Created by Tom Baranes on 16/01/2019.
//  Copyright © 2019 Toygar Dündaralp. All rights reserved.
//

import UIKit
import AVKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let testUrl = URL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")!
        Youtube.h264videosWithYoutubeURL(testUrl) { [weak self] videoInfo, error in
            if let videoUrl = videoInfo?["url"] as? String, let url = URL(string: videoUrl) {
                self?.playVideo(at: url)
            }
        }
    }

    private func playVideo(at url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.showsPlaybackControls = true
        playerViewController.player = player
        present(playerViewController, animated: true)
    }

}
