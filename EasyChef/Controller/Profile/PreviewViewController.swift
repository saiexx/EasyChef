//
//  PreviewViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/5/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class PreviewViewController: UIViewController {

    var name:String?
    var serving:String?
    var estimatedTime:Int?
    
    var ingredientsDict:[String:[String:String]] = [:]
    var directionsDict:[String:String] = [:]
    
    var ingredientsArr:[String] = []
    
    var image:UIImage?
    
    let user = Auth.auth().currentUser!
    
    @IBOutlet weak var previewTableView: UITableView!
    
    let tableHeaderViewHeight: CGFloat = UIScreen.main.bounds.height / 4
    
    var headerView: MenuHeaderView!
    var headerMaskLayer: CAShapeLayer!
    
    var editStatus:Bool = false
    var foodId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderView()
    }
    
    func setupTableView() {
        previewTableView.dataSource = self
        previewTableView.delegate = self
        previewTableView.rowHeight = UITableView.automaticDimension
        previewTableView.separatorColor = UIColor.clear
        previewTableView.allowsSelection = false
    }
    
    func setupHeaderView() {
        headerView = previewTableView.tableHeaderView as? MenuHeaderView
        
        previewTableView.tableHeaderView = nil
        previewTableView.addSubview(headerView)
        
        previewTableView.contentInset = UIEdgeInsets(top: tableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        previewTableView.contentOffset = CGPoint(x: 0, y: -tableHeaderViewHeight + 64)
        
        let effectiveHeight = tableHeaderViewHeight
        
        previewTableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        previewTableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        headerView.foodImageView.image = image
        
        updateHeaderView()
    }
    
    func updateHeaderView() {
        let effectiveHeight = tableHeaderViewHeight
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: previewTableView.bounds.width, height: tableHeaderViewHeight)
        
        if previewTableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = previewTableView.contentOffset.y
            headerRect.size.height = -previewTableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PreviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! FoodDescriptionTableViewCell
            
            cell.nameLabel.text = name!
            cell.estimatedTimeLabel.text = "\(estimatedTime!) minutes"
            cell.servedLabel.text = serving!
            cell.profileButton.setTitle(user.displayName, for: .normal)
            
            return cell
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell", for: indexPath) as! IngredientsTableViewCell
            
            var ingredientsText = ""
            
            for index in 1...ingredientsDict.count {
                let name = ingredientsDict["\(index)"]!["name"]!
                let amount = ingredientsDict["\(index)"]!["amount"]!
                var text = ""
                
                if index == ingredientsDict.count {
                    text = "\(name) - \(amount)"
                } else {
                    text = "\(name) - \(amount)\n\n"
                }
                
                ingredientsText += text
            }
            
            cell.ingredientsLabel.text = ingredientsText
            cell.ingredientsLabel.numberOfLines = 0
            
            return cell
        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell", for: indexPath) as! DirectionTableViewCell
            
            var directionText = ""
            var text = ""
            
            for index in 1...directionsDict.count {
                let tempText = directionsDict["\(index)"]
                if index == directionsDict.count {
                    text = "\(index). \(tempText!)"
                } else {
                    text = "\(index). \(tempText!) \n\n"
                }
                directionText += text
            }
            
            cell.directionLabel.text = directionText
            cell.directionLabel.numberOfLines = 0
            
            return cell
        } else if indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewButtonCell", for: indexPath) as! ReviewButtonTableViewCell
            
            cell.reviewButton.layer.cornerRadius = 5
            
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmButtonCell", for: indexPath) as! ConfirmButtonTableViewCell
            
            cell.confirmButton.layer.cornerRadius = 5
            cell.editButton.layer.cornerRadius = 5
            
            if editStatus {
                cell.confirmButton.setTitle("Confirm", for: .normal)
            }
            
            cell.delegate = self
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension PreviewViewController: ConfirmButtonTableViewCellDelegate {
    
    func editButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonPressed() {
        print("confirm")
        uploadPhotoToStorage()
    }
    
}

//MARK: FIREBASE
extension PreviewViewController {
    
    func createNewMenu(imageUrl:URL) {
        let foodDB = FirestoreReferenceManager.menusDB
        
        let ownerName = user.displayName!
        let ownerId = user.uid
        let now = Date()
        
        let imgUrl = imageUrl.absoluteString
        var ref: DocumentReference? = nil
        
        ref = foodDB.addDocument(data: [
            "name": name!,
            "ownerName": ownerName,
            "ownerId": ownerId,
            "rating": ["amount":0, "sumRating":0],
            "estimatedTime": estimatedTime!,
            "served": serving!,
            "createdTime": now,
            "ingredients": ingredientsDict,
            "method": directionsDict,
            "imageUrl": imgUrl,
            "searchIngredients": ingredientsArr
        ]) { error in
            if let error = error {
                print("Error Creating New Menu: \(error)")
            } else {
                print("Menu Successfully Created")
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func editMenu(imageUrl:URL) {
        let foodDB = FirestoreReferenceManager.menusDB.document(foodId!)
        let imgUrl = imageUrl.absoluteString
        foodDB.updateData([
            "name": name!,
            "estimatedTime": estimatedTime!,
            "served": serving!,
            "ingredients": ingredientsDict,
            "method": directionsDict,
            "imageUrl": imgUrl
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func uploadPhotoToStorage() {
        let date = Date().timeIntervalSince1970
        
        guard let data = image!.jpegData(compressionQuality: 1.0) else {
            print("error")
            return
        }
        
        let imageName = "menu_\(date).jpg"
        
        let imageReference = Storage.storage().reference()
            .child("menuImage").child(imageName)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageReference.putData(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Upload Successful")
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("Get download Url")
                if self.editStatus {
                    self.editMenu(imageUrl: url!)
                } else {
                    self.createNewMenu(imageUrl: url!)
                }
            }
        }
    }
    
    
}
