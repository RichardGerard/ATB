//
//  VideoPlayerView.swift
//  ATB
//
//  Created by YueXi on 3/22/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import AVFoundation

// https://github.com/frelei/VideoView/tree/master/Video
// MARK: - VideoPlayerView
class VideoPlayerView: UIView {

    var isLoop: Bool = false
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(withUrl url: String) {
        if let videoURL = URL(string: url) {
            player = AVPlayer(url: videoURL)
            player?.volume = 0
            player?.isMuted = true
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = .resize
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }

    
    func play() {
        if player?.timeControlStatus != .playing {
            player?.play()
        }
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        
//        print("video stopped")
    }
    
    @objc private func reachTheEndOfTheVideo(_ notification: Notification) {
        guard isLoop else { return }
        
//        print("reached to the end, repeating")
        
        player?.pause()
        player?.seek(to: .zero)
        player?.play()
    }
}
