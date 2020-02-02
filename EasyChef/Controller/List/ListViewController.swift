//
//  ListViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var listCollectionView: UICollectionView!
    
    let alertService = AlertService()
    let userID = Auth.auth().currentUser?.uid
    
    var nameList:[String] = []
    var userList:[String:[String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustCellPadding()
        fetchUserList()
        
        self.listCollectionView.dataSource = self
        self.listCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !checkLoginStatatus() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = alertService.addListAlert(){ (text) in
            self.updateList(newList: text)
        }
        self.present(alert, animated: true)
    }
    
    func fetchUserList() {
        let userDB = FirestoreReferenceManager.usersDB.document(Auth.auth().currentUser!.uid)
        userDB.getDocument{ (document, error) in
            if let document = document, document.exists {
                
                self.userList = document.get("myList") as! [String:[String]]
                var temporaryNameList:[String] = []
                
                for list in self.userList {
                    temporaryNameList.append(list.key)
                }
                self.nameList = temporaryNameList

                self.listCollectionView.reloadData()
                print("fetched")
            }
        }
    }
    
    func updateList(newList: String) {
        let userDB = FirestoreReferenceManager.usersDB.document(userID!)
        userList[newList] = []
        userDB.updateData([
            "myList": userList
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                self.fetchUserList()
                print("Document Successfully Updated")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "List", for: indexPath) as! ListCollectionViewCell
        
        cell.listLabel.text = nameList[indexPath.row % 5]
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        return cell
    }
}

extension ListViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 25
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize, height: collectionView.frame.size.height/8)
    }
    
    func adjustCellPadding() {
        let layout = self.listCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
    }
}
