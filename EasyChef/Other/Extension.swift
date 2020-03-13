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

