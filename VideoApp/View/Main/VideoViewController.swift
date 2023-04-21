//
//  ViewController.swift
//  VideoApp
//
//  Created by 이재훈 on 2023/04/21.
//

import UIKit
import SnapKit
import PhotosUI

class VideoViewController: UIViewController {
    
    var videoView = VideoView()
    
    lazy var pickerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(tappedPickerButton))
        button.tintColor = .white
        return button
    }()
    
    lazy var picker: PHPickerViewController = {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selection = .default
        config.selectionLimit = 1
        
        var picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
}

extension VideoViewController {
    func setupLayout() {
        self.view.backgroundColor = .systemPink
        self.title = "Video"
        self.navigationItem.rightBarButtonItem = pickerButton
        
        [videoView].forEach{
            self.view.addSubview($0)
        }
        
        videoView.snp.makeConstraints{
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    @objc func tappedPickerButton(_ sender: UIBarButtonItem) {
        picker.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(picker, animated: true)
   }
}

extension VideoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        itemProvider?.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier){url, error in
            if let url = url {
                
                DispatchQueue.main.sync { [weak self] in
                    guard let self = self else {return}
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
}
