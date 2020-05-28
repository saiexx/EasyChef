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

    @IBOutlet weak var listCollectionView: UICollectionView!
    
    let alertService = AlertService()
    let userID = Auth.auth().currentUser?.uid
    
    var nameList:[String] = []
    var userList:[String:[String]] = [:]
    
    var selectedList:String?
    
    var longPressGesture = UILongPressGestureRecognizer()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        if !checkLoginStatatus() {
            if let vc = presentingViewController as? WelcomeViewController {
                vc.didUserNotLogin = true
            }
            self.dismiss(animated: true, completion: nil)
            return
        }
        adjustCellPadding()
        setupLongPressGesture()
        self.listCollectionView.dataSource = self
        self.listCollectionView.delegate = self
        listCollectionView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserList()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = alertService.addListAlert(for: "add"){ (text) in
            self.updateList(for: "add", newList: text, currentList: "")
        }
        self.present(alert, animated: true)
    }
    
    // MARK: Fetch User's List in Firestore
    func fetchUserList() {
        let userDB = FirestoreReferenceManager.usersDB.document(Auth.auth().currentUser!.uid)
        userDB.getDocument{ (document, error) in
            if let document = document, document.exists {
                
                self.userList = document.get("myList") as! [String:[String]]
                var temporaryNameList:[String] = ["Favorite"]
                
                for list in self.userList {
                    if list.key != "Favorite" {
                        temporaryNameList.append(list.key)
                    }
                }
                self.nameList = temporaryNameList

                self.listCollectionView.reloadData()
                print("List Fetched")
            }
        }
    }
    
    // MARK: Update Users's List and Update in Firestore
    func updateList(for type:String, newList: String, currentList: String) {
        let userDB = FirestoreReferenceManager.usersDB.document(userID!)
        switch type {
        case "add":
            userList[newList] = []
        case "delete":
            userList.removeValue(forKey: newList)
        case "rename":
            print(userList[currentList])
            userList[newList] = userList[currentList]
            userList.removeValue(forKey: currentList)
        default:
            print("Invalid Type")
            return
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectedList" {
            let destinationVC = segue.destination as! SelectedListViewController
            destinationVC.listName = selectedList
        }
    }
}
// MARK: CollectionView
extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "List", for: indexPath) as! ListCollectionViewCell
        
        if nameList[indexPath.row] == "Favorite" {
            cell.iconImageView.image = UIImage(named: "icon-heart")
        } else {
            cell.iconImageView.image = UIImage(named: "icon-userList")
        }
        cell.listLabel.text = nameList[indexPath.row]
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedList = nameList[indexPath.row]
        segueWithoutSender(destination: "goToSelectedList")
    }
}

extension ListViewController:UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    // MARK: AdjustCollectionViewCell
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
    
    // MARK: LongPressGesture
    func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ListViewController.handleLongPressGesture(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 1
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        self.listCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {

        let press = gestureRecognizer.location(in: listCollectionView)
        let indexPath = listCollectionView.indexPathForItem(at: press)
        let cell = listCollectionView.cellForItem(at: indexPath!)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            cell?.backgroundColor = UIColor.lightGray
            cell?.layer.borderColor = UIColor.darkGray.cgColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                cell?.backgroundColor = UIColor.white
                cell?.layer.borderColor = UIColor.lightGray.cgColor
                
                if let index = indexPath {
                    if self.nameList[index.row] == "Favorite" {
                        let alert = UIAlertController(title: "You Cannot Rename or Delete Favorite", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    self.displayAdjustCellActionSheet(list: self.nameList[index.row])
                } else {
                    print("Couldn't find index path")
                }
            }
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            return
        }
        
    }
    
    // MARK: ActionSheet And Alert
    func displayAdjustCellActionSheet(list:String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Rename", style: .default){ action in
            let alert = self.alertService.addListAlert(for: "rename"){ (text) in
                self.updateList(for: "rename", newList: text, currentList: list)
            }
            self.present(alert, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive){ action in
            self.displayDeleteCellAlert(list: list)
        })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func displayDeleteCellAlert(list:String) {
        let alert = UIAlertController(title: "Delete \(list)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive){ action in
            self.updateList(for: "delete", newList: list, currentList: "")
        })
        self.present(alert, animated: true)
    }
}
