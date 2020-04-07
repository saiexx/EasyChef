//
//  HomeViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeViewController: UIViewController{
    
    var menuData:[Menu] = []
    
    let db = FirestoreReferenceManager.menusDB
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    var selectedMenu:String?
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchMenu), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        addNavBarImage(viewController: self)
        fetchMenu()
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.delegate = self
        adjustCellPadding()
        
        menuCollectionView.refreshControl = refresher
    }
    
    @objc func fetchMenu() {
        menuData = []
        db.order(by: "createdTime", descending: true).getDocuments() { (query, error) in
            if let error = error {
                print("Something went wrong \(error)")
            } else {
                for document in query!.documents {
                    let menu = document.data()
                    
                    let name = menu["name"] as! String
                    let foodId = document.documentID
                    let ownerName = menu["ownerName"] as! String
                    let imageUrlString = menu["imageUrl"] as! String
                    let estimatedTime = menu["estimatedTime"] as! Int
                    let rating = menu["rating"] as! [String:Int]
                    let served = menu["served"] as! String
                    let createdTimeTimestamp = menu["createdTime"] as! Timestamp
                    let createdTime = TimeInterval(createdTimeTimestamp.seconds)
                    
                    let menuStruct = Menu(forList: name, id: foodId, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime)
                    
                    self.menuData.append(menuStruct)
                    self.menuCollectionView.reloadData()
                    self.endRefresher()
                }
            }
        }
    }
    func endRefresher() {
        let deadline = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToViewMenuScreen" {
            let destination = segue.destination as! ViewMenuViewController
            destination.foodId = selectedMenu
        }
    }
}

extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuData.count
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

extension HomeViewController:UICollectionViewDelegateFlowLayout {
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

