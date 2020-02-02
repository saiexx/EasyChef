//
//  ListViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage(viewController: self)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if !checkLoginStatatus() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkLoginStatatus() -> Bool{
        return Auth.auth().currentUser != nil
    }

}
