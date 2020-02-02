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
        goToMainScreen()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("goToLoginScreen")
        goToLoginScreen()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("goToRegisterScreen")
        goToRegisterScreen()
    }
    
    func goToMainScreenIfAuth() {
        if checkLoginStatatus() {
            goToMainScreen()
            print("Logged")
        }
    }
    
    func checkLoginStatatus() -> Bool{
        return Auth.auth().currentUser != nil
    }
    
    // segue destination
    func goToMainScreen() {
        performSegue(withIdentifier: "goToMainScreen", sender: nil)
    }
    
    func goToLoginScreen() {
        performSegue(withIdentifier: "goToLoginScreen", sender: nil)
    }
    
    func goToRegisterScreen() {
        performSegue(withIdentifier: "goToRegisterScreen", sender: nil)
    }

}
