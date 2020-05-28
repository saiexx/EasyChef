//
//  ViewMenuViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 9/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class ViewMenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    var foodId:String?
    
    var currentMenu: Menu!
    var currentMenuTag:Bool = false
    var currentIngredientsArr:[String] = []
    var currentIngredientsName:String = ""
    var substituteIngredients:String = ""
    
    let user = Auth.auth().currentUser
    
    var userList:[String] = []
    var userListDict:[String:[String]] = [:]
    
    var commentData:[Comment] = []
    var userCommentList:[String] = []
    
    let tableHeaderViewHeight: CGFloat = UIScreen.main.bounds.height / 4
    
    var headerView: MenuHeaderView!
    var headerMaskLayer: CAShapeLayer!
    
    var reviewButtonStatus:Bool = false
    
    var ownerStatus:Bool = false
    
    @IBOutlet weak var barButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchMenu()
        fetchComment()
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        if ownerStatus {
            showConfigMenuActionSheet()
        } else {
            fetchUserList()
        }
    }
    
    func setupTableView() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.rowHeight = UITableView.automaticDimension
        menuTableView.estimatedRowHeight = menuTableView.rowHeight
        menuTableView.separatorColor = UIColor.clear
        menuTableView.allowsSelection = false
    }
    
    func fetchMenu() {
        let menu = FirestoreReferenceManager.menusDB.document(foodId!)
        menu.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let menu = document!.data() else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            let name = menu["name"] as! String
            let ownerName = menu["ownerName"] as! String
            let imageUrlString = menu["imageUrl"] as! String
            let estimatedTime = menu["estimatedTime"] as! Int
            let rating = menu["rating"] as! [String:Int]
            let served = menu["served"] as! String
            let createdTimeTimestamp = menu["createdTime"] as! Timestamp
            let createdTime = TimeInterval(createdTimeTimestamp.seconds)
            let ingredients = menu["ingredients"] as! [String:[String:String]]
            let method = menu["method"] as! [String:String]
            let ownerId = menu["ownerId"] as! String
            self.currentMenu = Menu(forView: name, id: self.foodId!, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime, ingredients: ingredients, method: method, ownerId: ownerId)
            self.menuTableView.reloadData()
            self.headerView.foodImageView.kf.setImage(with: self.currentMenu?.imageUrl)
            
            if self.currentMenuTag {
                for subIngredient in self.currentIngredientsArr {
                    for (_,menuIngredient) in self.currentMenu.ingredients {
                        if menuIngredient["name"]! == subIngredient {
                            self.substituteIngredients = subIngredient
                            break
                        }
                    }
                }
            }
            
            if !self.checkLoginStatatus() {
                self.barButton.isHidden = true
            } else {
                self.checkOwnerStatus()
            }
            print("Fetch Menu Success")
        }
    }
    
    func fetchUserList() {
        let userDB = FirestoreReferenceManager.usersDB.document(user!.uid)
        userDB.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let data = document!.data()
            let list = data!["myList"]! as! [String:[String]]
            var tempList:[String] = []
            self.userListDict = list
            for key in list.keys { tempList.append(key) }
            self.userList = tempList.sorted()
            self.showActionSheet()
            print("Fetch User List Success")
        }
    }
    
    //fetch comment db
    func fetchComment() {
        commentData = []
        userCommentList = []
        let commentDB = FirestoreReferenceManager.menusDB.document(foodId!).collection("review")
        commentDB.order(by: "time", descending: true).getDocuments { (query, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            for document in query!.documents {
                let comment = document.data()
                
                let name = comment["name"] as! String
                let commentId = document.documentID
                let imageUrl = comment["imageUrl"] as! String
                let score = comment["rating"] as! Int
                let commentText = comment["comment"] as! String
                let createdTimeTimestamp = comment["time"] as! Timestamp
                let createdTime = TimeInterval(createdTimeTimestamp.seconds)
                let ownerId = comment["ownerId"] as! String
                
                let commentClass = Comment(name: name, commentId: commentId, imageUrl: imageUrl, createdTime: createdTime, commentText: commentText, score: score, ownerId: ownerId)
                
                self.userCommentList.append(ownerId)
                
                self.commentData.append(commentClass)
                self.checkUserCommentStatus()
                self.menuTableView.reloadData()
            }
        }
    }
    
    func checkOwnerStatus() {
        if currentMenu.ownerId == user!.uid {
            ownerStatus = true
            print("owner")
            barButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        } else {
            ownerStatus = false
            barButton.setImage(UIImage(systemName: "plus"), for: .normal)
            print("not owner")
        }
    }
    
    func checkUserCommentStatus() {
        if userCommentList.contains(user!.uid) {
            reviewButtonStatus = true
        }
    }
    
    //setup for stretchy header
    func setupHeaderView() {
        headerView = menuTableView.tableHeaderView as? MenuHeaderView
        
        menuTableView.tableHeaderView = nil
        menuTableView.addSubview(headerView)
        
        menuTableView.contentInset = UIEdgeInsets(top: tableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        menuTableView.contentOffset = CGPoint(x: 0, y: -tableHeaderViewHeight + 64)
        
        let effectiveHeight = tableHeaderViewHeight
        
        menuTableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        menuTableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        updateHeaderView()
    }
    
    //update header when scrolling down
    func updateHeaderView() {
        let effectiveHeight = tableHeaderViewHeight
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: menuTableView.bounds.width, height: tableHeaderViewHeight)
        
        if menuTableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = menuTableView.contentOffset.y
            headerRect.size.height = -menuTableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    //generate rating star based on rating score
    func setRatingStar(averageRating: Double?, starImage:[UIImageView]) {
        let filledStar = #imageLiteral(resourceName: "filled-star")
        let blankStar = #imageLiteral(resourceName: "blank-star")
        var counter = 1
        if averageRating == nil {
            for star in starImage {
                star.image = nil
            }
            return
        }
        let intRating = Int(averageRating!)
        for star in starImage {
            if counter <= intRating {
                star.image = filledStar
            } else {
                star.image = blankStar
            }
            counter += 1
        }
    }
}

//MARK: TABLEVIEW
extension ViewMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentMenu == nil {
            return 0
        } else {
            return 4 + commentData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! FoodDescriptionTableViewCell
            
            cell.nameLabel.text = currentMenu?.name
            setRatingStar(averageRating: currentMenu?.averageRating, starImage: cell.starImageView)
            cell.ratingLabel.text = String(format:"%.1f(\(currentMenu!.numberOfUserRated!))", currentMenu!.averageRating!)
            cell.estimatedTimeLabel.text = "\(currentMenu!.estimatedTime!) minutes"
            cell.servedLabel.text = currentMenu!.served!

            cell.profileButton.setTitle(currentMenu!.ownerName!, for: .normal)
            
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell", for: indexPath) as! IngredientsTableViewCell
            
            let ingredients = currentMenu!.ingredients
            var ingredientsText = ""
            var checker = false
            
            for index in 1...ingredients.count {
                let name = ingredients["\(index)"]!["name"]!
                let amount = ingredients["\(index)"]!["amount"]!
                var text = ""
                
                if amount == "" {
                    if index == ingredients.count{
                        text = "\(name)"
                    } else {
                        text = "\(name)\n\n"
                    }
                } else {
                    if index == ingredients.count {
                        text = "\(name) - \(amount)"
                    } else {
                        text = "\(name) - \(amount)\n\n"
                    }
                }
                
                if name == substituteIngredients {
                    checker = true
                }
                ingredientsText += text
            }
            
            if checker {
                cell.substituteLabel.text = "*สามารถใช้\(currentIngredientsName)แทน\(substituteIngredients)ได้"
                cell.substituteLabel.isHidden = false
            }
            
            cell.ingredientsLabel.text = ingredientsText
            cell.ingredientsLabel.numberOfLines = 0
            
            return cell

        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell", for: indexPath) as! DirectionTableViewCell
            
            let direction = currentMenu!.method
            var directionText = ""
            var text = ""
            
            for index in 1...direction.count {
                let tempText = direction["\(index)"]
                if index == direction.count {
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
            
            let amount = commentData.count
            if amount <= 1 {
                cell.amountLabel.text = "\(amount) Review"
            } else {
                cell.amountLabel.text = "\(amount) Reviews"
            }
            
            cell.reviewButton.layer.cornerRadius = 5
            
            if reviewButtonStatus || ownerStatus {
                cell.reviewButton.isEnabled = false
            }
            
            if !checkLoginStatatus() {
                cell.reviewButton.isEnabled = false
                cell.reviewButton.setTitle("You need to login first to review this menu.", for: .normal)
            }
            
            cell.delegate = self
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsTableViewCell
            
            let index = indexPath.row - 4
            
            cell.nameLabel.text = commentData[index].name!
            cell.commentLabel.text = commentData[index].commentText!
            
            let date = Date(timeIntervalSince1970: commentData[index].createdTime!)
            cell.timeLabel.text = date.timeAgoDisplay()
            
            setRatingStar(averageRating: Double(commentData[index].score!), starImage: cell.starImageView)
            
            return cell
        }
    }
}

extension ViewMenuViewController: ReviewButtonTableViewCellDelegate {
    func ReviewButtonPressed() {
        segueWithoutSender(destination: "goToReviewScreen")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToReviewScreen" {
            let destination = segue.destination as! ReviewViewController
            destination.food = currentMenu
        } else if segue.identifier == "goToEdit" {
            let destination = segue.destination as! CreateMenuViewController
            destination.currentMenu = currentMenu
            destination.editStatus = true
        }
    }
}

extension ViewMenuViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
}

// MARK: ALERT
extension ViewMenuViewController {
    func showConfigMenuActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default) { action in self.segueWithoutSender(destination: "goToEdit")})
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in self.showDeleteAlert() })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func showDeleteAlert() {
        let alert = UIAlertController(title: nil, message: "Delete this menu?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default) { action in self.deleteMenu() })
        
        self.present(alert, animated: true)
    }
    func showActionSheet() {
        let alert = UIAlertController(title: nil, message: "Select your list", preferredStyle: .actionSheet)
        
        for name in userList {
            alert.addAction(UIAlertAction(title: name, style: .default) { action in self.addToList(selectedList: name)})
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func showExistingMenuAlert(name:String, selectedList:String) {
        let alert = UIAlertController(title: "You already have \(name) in \(selectedList).", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func addToList(selectedList:String) {
        print(selectedList)
        var newList = userListDict[selectedList]
        if (newList?.contains(foodId!))! {
            showExistingMenuAlert(name: currentMenu.name!, selectedList: selectedList)
            return
        }
        newList?.append(foodId!)
        userListDict.updateValue(newList!, forKey: selectedList)
        print(userListDict)
        
        let userDB = FirestoreReferenceManager.usersDB.document(user!.uid)
        
        userDB.updateData([
            "myList": userListDict
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document Successfully Updated")
            }
        }
    }
    
    func deleteMenu() {
        let foodDB = FirestoreReferenceManager.menusDB.document(foodId!)
        foodDB.delete { (error) in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Menu successfully removed")
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
