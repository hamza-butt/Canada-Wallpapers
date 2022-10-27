//
//  UIViewController.swift
//  WallPaperApp
//
//  Created by Hamza Butt on 10/13/22.
//  Copyright © 2022 Mitesh's MAC. All rights reserved.
//

import Loaf
import UIKit

class Utility {
    
    static func alertMessage(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default,
                handler: nil
            ))
            guard let window : UIWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {return}
            var presentVC = window.rootViewController
            while let next = presentVC?.presentedViewController {
                presentVC = next
            }
            presentVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    class func showLoaf(message: String, state: Loaf.State,location: Loaf.Location = .top) {
        DispatchQueue.main.async {
            guard let window : UIWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {return}
            var presentVC = window.rootViewController
            while let next = presentVC?.presentedViewController {
                presentVC = next
            }
            guard let presenter = presentVC else {
                Utility.alertMessage(title: "", message: message)
                return
            }
            switch state {
            case .success:
                Loaf(message, state: .success,location: location, sender: presenter).show()
            case .warning:
                Loaf(message, state: .warning,location: location, sender: presenter).show()
            case .error:
                Loaf(message, state: .error,location: location, sender: presenter).show()
            default:
                return
            }
        }
    }
 }

