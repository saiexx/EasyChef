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
    var menuList:[String] = []
    var menuData:[Menu] = []
    
    let menuDB = FirestoreReferenceManager.menusDB
    let userID = Auth.auth().currentUser?.uid
    
    var selectedMenu:String?
    
    var longPressGesture = UILongPressGestureRecognizer()
    
    @IBOutlet weak var menuCollectionView: UICollectionView!

    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.delegate = self
        
        adjustCellPadding()
        setupLongPressGesture()
        fetchUserList()
        print(listName!)
    }
    
    func fetchUserList() {
        let userDB = FirestoreReferenceManager.usersDB.document(userID!)
        userDB.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let data = document!.data()
            let list = data!["myList"]! as! [String:[String]]
            self.nameList = list
            let selectedList = list[self.listName!]!
            self.menuList = selectedList
            
            print("Fetch \(self.listName!) Success")
            
            self.fetchMenu()
        }
    }
    
    func fetchMenu() {
        var counter = 0
        menuData = []
        if menuList.count == 0 {
            menuCollectionView.reloadData()
        }
        for id in menuList {
            menuDB.document(id).getDocument { (document, error) in
                if let error = error {
                    print("Something went wrong \(error)")
                } else {
                    let menu = document!.data()!
                    
                    let name = menu["name"] as! String
                    let foodId = id
                    let ownerName = menu["ownerName"] as! String
                    let imageUrlString = menu["imageUrl"] as! String
                    let estimatedTime = menu["estimatedTime"] as! Int
                    let rating = menu["rating"] as! [String:Int]
                    let served = menu["served"] as! String
                    let createdTimeTimestamp = menu["createdTime"] as! Timestamp
                    let createdTime = TimeInterval(createdTimeTimestamp.seconds)
                    
                    let menuStruct = Menu(forList: name, id: foodId, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime)
                    
                    self.menuData.append(menuStruct)
                    
                    counter += 1
                    if counter == self.menuList.count {
                        self.menuCollectionView.reloadData()
                        print("Fetch \(self.listName!) Menu Success")
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToViewMenuScreen" {
            let destination = segue.destination as! ViewMenuViewController
            destination.foodId = selectedMenu
        }
    }
}

extension SelectedListViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath) as! MenuCollectionViewCell
        
        let row = indexPath.row
        
        cell.foodNameLabel.text = menuData[row].name
        cell.ownerLabel.text = menuData[row].ownerName
        cell.ratingLabel.text = String(format:"%.1f(\(menuData[row].numberOfUserRated!))", menuData[row].averageRating!)
        cell.servedLabel.text = menuData[row].served
        cell.timeLabel.text = String(menuData[row].estimatedTime!) + "mins"
        cell.foodImageView.kf.setImage(with:menuData[row].imageUrl)
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMenu = menuData[indexPath.row].foodId
        segueWithoutSender(destination: "goToViewMenuScreen")
    }
}

extension SelectedListViewController:UICollectionViewDelegateFlowLayout {
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 25
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 200)
    }
    
    func adjustCellPadding() {
        let layout = self.menuCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
    }
}

extension SelectedListViewController:UIGestureRecognizerDelegate {
    func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SelectedListViewController.handleLongPressGesture(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 1
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        self.menuCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        let press = gestureRecognizer.location(in: menuCollectionView)
        let indexPath = menuCollectionView.indexPathForItem(at: press)
        let cell = menuCollectionView.cellForItem(at: indexPath!)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            cell?.backgroundColor = UIColor.lightGray
            cell?.layer.borderColor = UIColor.darkGray.cgColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cell?.backgroundColor = UIColor.white
                cell?.layer.borderColor = UIColor.lightGray.cgColor
                
                if let index = indexPath {
                    let name = self.menuData[index.row].name!
                    let id = self.menuData[index.row].foodId!
                    self.showActionSheet(id: id, name: name)
                } else {
                    print("Couldn't find index path")
                }
            }
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            return
        }
    }
}
extension SelectedListViewController {
    func showActionSheet(id:String, name:String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete \(name)", style: .destructive) {
            action in self.deleteMenu(id: id)
        })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func deleteMenu(id:String) {
        let index = menuList.firstIndex(of: id)!
        menuList.remove(at: index)
        nameList.updateValue(menuList, forKey: listName!)
        print(nameList)
        
        let userDB = FirestoreReferenceManager.usersDB.document(userID!)
        userDB.updateData([
            "myList": nameList
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                self.fetchUserList()
                print("Document Successfully Update")
                print("Delete \(id) Successful")
            }
        }
    }
}
