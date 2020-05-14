//
//  Extension.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 27/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension UIViewController {
    
    func addNavBarImage(viewController: UIViewController) {
        
        let navController = navigationController!
        
        let image = #imageLiteral(resourceName: "eazichef")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
    }
    
    func configureRoundProfileImage(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func checkLoginStatatus() -> Bool{
        return Auth.auth().currentUser != nil
    }
    
    func segueWithoutSender(destination:String) {
        performSegue(withIdentifier: destination, sender: nil)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return  "less than minute"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }
        
        return "\(secondsAgo / week) weeks ago"
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension String {
    
    func isCharacter() -> Bool {
        return regex(pattern: ".*[^A-Za-z].*")
    }
    
    func isNumeric() -> Bool {
        return regex(pattern: ".*[^0-9].*")
    }
    
    func hasSpecialCharacters() -> Bool {
        return !regex(pattern: ".*[^A-Za-z0-9].*")
    }
    
    func isEmailFormat() -> Bool {
        return !regex(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
    }
    
    func regex(pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        if regex.matches(in: self, options: [], range: range).count > 0 {
            return false
        }
        return true
    }
}
