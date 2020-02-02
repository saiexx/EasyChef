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

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let name = "ผัดไทยกุ้งสด"
    let ownerName = "Kanor"
    let rating:Double = 5
    let served = "1-2"
    let estimatedTime = 10
    
    let db = FirestoreReferenceManager.menusDB
    
    //let padthai = Menu()fromDisplayMenuList: "ผัดไทยกุ้งสด", ownerName: "Kanor", imageUrl:NS URL(string: #"https://firebasestorage.googleapis.com/v0/b/kmitl-semantic-cooking.appspot.com/o/menuImage%2Fผัดไทย.jpg?alt=media&token=43bc4d9f-a941-4fc2-9ae9-4d2a2ccc8ea0"# as! URL), rating: 5, served: "1-2", estimatedTime: 10)
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage(viewController: self)
        
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.delegate = self
        
        adjustCellPadding()
        
        db.getDocuments() { (query, error) in
            if let error = error {
                print("Something went wrong \(error)")
            } else {
                for document in query!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath) as! MenuCollectionViewCell
        
        cell.foodNameLabel.text = name
        cell.ownerLabel.text = ownerName
        cell.ratingLabel.text = String(format:"%.1f", rating)
        cell.servedLabel.text = served
        cell.timeLabel.text = String(estimatedTime) + "mins"
        cell.foodImageView.kf.setImage(with: Auth.auth().currentUser?.photoURL)
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        

        return cell
    }
    
}

extension HomeViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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

