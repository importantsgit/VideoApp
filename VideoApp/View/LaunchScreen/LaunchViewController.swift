//
//  LaunchViewController.swift
//  VideoApp
//
//  Created by 이재훈 on 2023/04/21.
//

import UIKit
import AVFoundation
import SnapKit

class LaunchViewController: UIViewController {
    
    let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "VideoApp"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
    
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Consts.consts.IS_DEBUG {
            self.changeView(0)
        } else {
            self.setupLayout()
            self.checkPremissions()
        }
    }
}

extension LaunchViewController {
    
    private func setupLayout() {
        self.view.backgroundColor = .systemPink
        [titleLabel].forEach{
            self.view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }

    func checkPremissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else {return}
                self.changeView(5)
                if !granted {
                    self.showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            changeView(5)
        }
    }
    
    private func showPermissionsAlert() {
        showAlert(
            withTitle: "카메라 접근",
            message: "유저의 카메라를 사용하기 위해 설정에서 접근권한을 설정하셔야 합니다.")
    }
    
    func changeView(_ time: Int) {
        let DelayTime = DispatchTimeInterval.seconds(time)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+DelayTime) {
                let rootViewController = VideoViewController()
                let navigationViewController = UINavigationController(rootViewController: rootViewController)
                sceneDelegate.changeRootVC(navigationViewController, animated: true)
            }
        }
    }
}
