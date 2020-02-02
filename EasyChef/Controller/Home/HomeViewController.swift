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
    
    let imageUrl = URL(string: #"https://www.google.com/url?sa=i&url=http%3A%2F%2Fwww.bbc.com%2Ftravel%2Fstory%2F20180227-is-this-thailands-best-pad-thai&psig=AOvVaw1CUhPZagusXdvL8HmSuIVc&ust=1580718873752000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCODukeq6sucCFQAAAAAdAAAAABAD"#)
    
    //let padthai = Menu()fromDisplayMenuList: "ผัดไทยกุ้งสด", ownerName: "Kanor", imageUrl:NS URL(string: #"https://firebasestorage.googleapis.com/v0/b/kmitl-semantic-cooking.appspot.com/o/menuImage%2Fผัดไทย.jpg?alt=media&token=43bc4d9f-a941-4fc2-9ae9-4d2a2ccc8ea0"# as! URL), rating: 5, served: "1-2", estimatedTime: 10)
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage(viewController: self)
        
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.delegate = self
        
        print(Auth.auth().currentUser?.photoURL)
        print(imageUrl)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath) as! MenuCollectionViewCell
        
        cell.foodNameLabel.text = name
        cell.ownerLabel.text = ownerName
        cell.ratingLabel.text = String(format:"%.1f", rating)
        cell.servedLabel.text = served
        cell.timeLabel.text = String(estimatedTime) + "mins"
        
        
        cell.foodImageView.kf.setImage(with: Auth.auth().currentUser?.photoURL)
        

        
        return cell
    }
    
}

extension HomeViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 25
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 200)
    }
}

