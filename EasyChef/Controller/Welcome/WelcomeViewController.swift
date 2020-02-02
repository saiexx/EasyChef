//
//  WelcomeViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToMainScreenIfAuth()
    }
    
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        print("goToMainScreen")
        segueWithoutSender(destination: "goToMainScreen")
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("goToLoginScreen")
        segueWithoutSender(destination: "goToLoginScreen")
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("goToRegisterScreen")
        segueWithoutSender(destination: "goToRegisterScreen")
    }
    
    func goToMainScreenIfAuth() {
        if checkLoginStatatus() {
            segueWithoutSender(destination: "goToMainScreen")
            print("Logged")
        }
    }

}
