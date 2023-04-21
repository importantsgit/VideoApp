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
        
    }
}
