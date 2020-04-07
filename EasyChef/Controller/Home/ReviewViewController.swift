//
//  ReviewViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 7/4/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ReviewViewController: UIViewController {
    
    let foodDB = FirestoreReferenceManager.menusDB
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet var starButton: [UIButton]!
    
    var currentStar = 0
    
    var food:Menu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRoundProfileImage(imageView: foodImageView)
        foodImageView.kf.setImage(with: food?.imageUrl)
        foodNameLabel.text = food?.name
        ownerNameLabel.text = food?.ownerName
        confirmButton.layer.cornerRadius = 5
        setRatingStar(star: currentStar)
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        currentStar = sender.tag
        setRatingStar(star: currentStar)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        createNewComment()
    }
    
    func createNewComment() {
        let user = Auth.auth().currentUser!
        
        let commentText = commentTextView.text
        let name = user.displayName
        let imageUrl = user.photoURL?.absoluteString
        let rating = currentStar
        let now = Date()
        let uid = user.uid
        
        foodDB.document(food!.foodId!)
            .collection("review")
            .document(uid)
            .setData([
                "comment": commentText!,
                "imageUrl": imageUrl!,
                "name": name!,
                "ownerId": uid,
                "rating": rating,
                "time": now
            ]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("Create Review Success")
                self.updateMenuRating()
        }
    }
    
    
    func setRatingStar(star: Int) {
        let filledStar = #imageLiteral(resourceName: "filled-star")
        let blankStar = #imageLiteral(resourceName: "blank-star")
        
        var counter = 1
        
        for button in starButton {
            if counter <= star {
                button.setImage(filledStar, for: .normal)
            } else {
                button.setImage(blankStar, for: .normal)
            }
            counter += 1
        }
    }
    
    func updateMenuRating() {
        var sumRating = (food?.sumRating)!
        var numberOfUserRated = (food?.numberOfUserRated!)!
        
        sumRating += currentStar
        numberOfUserRated += 1
        
        let rating = ["amount":numberOfUserRated, "sumRating": sumRating]
        
        foodDB.document(food!.foodId!).updateData([
            "rating": rating
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Update Food Rating Success")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
