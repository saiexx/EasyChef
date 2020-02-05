//
//  AddListViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class SelectedListViewController: UIViewController {
    
    var listName:String?
    var nameList:[String:[String]] = [:]
    
    let userID = Auth.auth().currentUser?.uid

    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(listName!)
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        displayMoreActionSheet()
    }
    
    func fetchUserList() {
        let userDB = FirestoreReferenceManager.usersDB.document()
    }
    
}

extension SelectedListViewController {
    func displayMoreActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete Menu ", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete List", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}
