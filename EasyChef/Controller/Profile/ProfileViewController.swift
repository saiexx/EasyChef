//
//  ProfileViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var styleLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRoundProfileImage(imageView: profileImageView)
        showUserProfile()
        
        self.navigationItem.title = user?.displayName ?? "User"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !checkLoginStatatus() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationItem.title = user?.displayName ?? "User"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserProfile()
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        segueWithoutSender(destination: "goToEditProfile")
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        if AccessToken.current != nil {
            facebookLogout()
        }
        firebaseLogout()
    }
    
    func showUserProfile() {
        let userDB = FirestoreReferenceManager.usersDB.document(user!.uid)
        
        userDB.getDocument{ (document, error) in
            if let document = document, document.exists {
                let about = document.get("about")
                let style = document.get("style")
                
                self.aboutLabel.text = (about as! String)
                self.styleLabel.text = (style as! String)
                
                if let imageUrl = Auth.auth().currentUser?.photoURL {
                    self.profileImageView.kf.setImage(with: imageUrl)
                }
            }
        }
        nameLabel.text = user?.displayName
        emailLabel.text = user?.email
    }
    
    func firebaseLogout() {
        do {
            try Auth.auth().signOut()
            print("logout success")
        } catch let signOutError as NSError {
            print ("Error signing out :%@", signOutError)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func facebookLogout() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }

}
