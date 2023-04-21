//
//  Extension.swift
//  VideoApp
//
//  Created by 이재훈 on 2023/04/21.
//

import UIKit

extension UIViewController {
    func showAlert(withTitle title: String, message: String,_ buttonText: String = "OK") {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: buttonText, style: .default))
            self.present(alertController, animated: true)
        }
    }
}

