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
    
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var profileTableView: UITableView!
    
    struct Storyboard {
        static let header = "HeaderCell"
        static let description = "DescriptionCell"
        static let ownedMenu = "NumberOfOwnedMenuCell"
        static let menuContent = "MenuContentCell"
    }
    
    var name:String?
    var email:String?
    var image:URL?
    var about:String?
    var style:String?
    var numberOfOwnedMenu:Int?
    var numberOfContent = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        //configureRoundProfileImage(imageView: profileImageView)
        showUserProfile()
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.rowHeight = UITableView.automaticDimension
        profileTableView.estimatedRowHeight = profileTableView.rowHeight
        profileTableView.separatorColor = UIColor.clear
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
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        displaySettingActionSheet()
    }
    
    @IBAction func createMenuButtonPressed(_ sender: Any) {
        segueWithoutSender(destination: "goToCreateMenu")
    }
    func showUserProfile() {
        let userDB = FirestoreReferenceManager.usersDB.document(user!.uid)
        
        userDB.getDocument{ (document, error) in
            if let document = document, document.exists {
                self.about = (document.get("about") as! String)
                self.style = (document.get("style") as! String)
                
                let ownedMenu:[String] = document.get("ownedMenu") as! [String]
                
                self.numberOfOwnedMenu = ownedMenu.count
                
                self.profileTableView.reloadData()
            }
        }
        if let imageUrl = user?.photoURL {
            image = imageUrl
        }
        name = user?.displayName
        email = user?.email
    }
    
    func logOut() {
        if AccessToken.current != nil {
            facebookLogout()
        }
        firebaseLogout()
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
extension ProfileViewController: HeaderTableViewCellDelegate {
    func profileButtonPressed() {
        segueWithoutSender(destination: "goToEditProfile")
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.header, for: indexPath) as! HeaderTableViewCell
            
            cell.nameLabel.text = name
            cell.emailLabel.text = email
            cell.profileButton.layer.cornerRadius = 5
            configureRoundProfileImage(imageView: cell.profileImageView)
            cell.profileImageView.kf.setImage(with: image)
            
            cell.delegate = self
            
            cell.selectionStyle = .none
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.description, for: indexPath) as! DescriptionTableViewCell
            
            cell.aboutLabel.text = about
            cell.styleLabel.text = style
            if cell.styleLabel.text == nil || cell.styleLabel.text == "" {
                cell.styleIconImageView.isHidden = true
            } else {
                cell.styleIconImageView.isHidden = false
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ownedMenu, for: indexPath) as! OwnedMenuTableViewCell
            
            if numberOfOwnedMenu ?? 0 > 1 {
                cell.ownedMenuLabel.text = "\(numberOfOwnedMenu!) Menus"
            } else {
                cell.ownedMenuLabel.text = "\(numberOfOwnedMenu ?? 0) Menu"
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.menuContent, for: indexPath) as! MenuContentTableViewCell
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            if let cell = cell as? MenuContentTableViewCell {
                cell.menuCollectionView.dataSource = self
                cell.menuCollectionView.delegate = self
                cell.menuCollectionView.isScrollEnabled = false
                cell.menuCollectionView.reloadData()
                
                let layout = cell.menuCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                layout.minimumInteritemSpacing = 5
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            if numberOfContent % 2 == 0 {
                return CGFloat(210*(numberOfContent/2))
            } else {
                return CGFloat(210*((numberOfContent+1)/2))
            }
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfContent
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OwnedFoodCollectionCell", for: indexPath) as! OwnedFoodCollectionViewCell
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 25
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 200)
    }
}

extension ProfileViewController {
    func displaySettingActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (action) in
            self.logOut()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
