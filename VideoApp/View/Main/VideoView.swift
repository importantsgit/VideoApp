//
//  VideoView.swift
//  VideoApp
//
//  Created by 이재훈 on 2023/04/21.
//

import UIKit
import SnapKit
import AVFoundation

class VideoView: UIView {
    
    var player: AVPlayer?
    var playerLayer = AVPlayerLayer()
    var av = AVPlayerItemVideoOutput()
    var timeObserverToken: Any?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoView {
    private func setupLayout() {
        self.backgroundColor = .black
    }
    
    // AVPlayerLayer
    func setupLayer() {
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resize
    }
    
    func play() {
        if let isPlaying = self.playerLayer.player?.isPlaying,
           !isPlaying {
            self.playerLayer.player?.play()
        }
    }
    
    func pause() {
        if let isPlaying = self.playerLayer.player?.isPlaying,
           isPlaying {
            self.playerLayer.player?.pause()
        }
    }
    
    func setURL(url: URL) {
        playerLayer.player == nil ? setPlayItem(url: url) : changePlayItem(url: url)
        addPeriodicTimeObserver()
    }
    
    func setPlayItem(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerLayer.player = self.player
        av = AVPlayerItemVideoOutput(outputSettings: playerLayer.pixelBufferAttributes)
    }
    
    func changePlayItem(url: URL) {
        removePeriodicTimeObserver()
        self.playerLayer.player = nil
        self.player = nil
        let playerItem = AVPlayerItem(url: url)
        let otherPlayer = AVPlayer(playerItem: playerItem)
        self.player = otherPlayer
        self.playerLayer.player = player
        
        //FIXME: replaceCurrentItemWithPlayer 수정
    }
    
    
    // 시간 관찰
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: .global(), using: { [weak self] time in
            guard let self = self else {return}
        })
    }
    
    // 이전에 등록된 시간 추가 혹은 시간 경계 관찰자를 취소
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

}

// AVPlayer 객체는 AVAsset의 전반적인 playback(녹음, 녹화, 재생)을 조절하는데 사용
// AVPlayer 객체가 AVPlayerItem을 이용하고, AVPlayerItem이 AVAsset을 사용하는 구조
// AVPlayer는 한 번에 하나의 미디어 데이터만 재생할 수 있으므로, 여러 미디어 데이터를 순서대로 재생하고 싶은 경우에는 AVQueuePlayer 클래스 사용
// AVAsset: 시간 상태 정보 가지고 있는 객체
// AVPlayerItem: 동적인 상태 관리 ( presentation state, 현재 시간, 현재까지 재생된 시간 등등 )
