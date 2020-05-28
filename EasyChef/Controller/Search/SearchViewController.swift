//
//  MenuViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 23/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var foodCollectionView: UICollectionView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var didSearchName:Bool = true
    
    var ingredientsArr:[String] = []
    var ingredientsDict:[String:[String]] = [:]
    
    var searchArr:[String] = []
    var searching = false
    
    var menuData:[Menu] = []
    
    var selectedMenu:String?
    var selectedMenuTag:Bool = false
    var selectedIngredients:[String] = []
    
    var searchedIngredients:String = ""
    
    var chosenName:String = ""
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchSearchIngredients()
        
        setupSearchBar()
        
        setupTableView()
        
        foodCollectionView.keyboardDismissMode = .interactive
        foodCollectionView.delegate = self
        foodCollectionView.dataSource = self
        
        adjustCellPadding()
        
        foodCollectionView.refreshControl = refresher
        
        iconImageView.alpha = 0.25
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedMenuTag = false
        selectedIngredients = []
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let tabbarHeight = self.tabBarController?.tabBar.frame.height ?? 0
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0 - tabbarHeight
            }
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    @objc func onRefresh() {
        searchByIngredients(chosenName: searchedIngredients)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func setupTableView() {
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        
        ingredientsTableView.isHidden = true
    }

    func setupSearchBar() {
        searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.textColor = UIColor.white
        let iconImage = textFieldInsideSearchBar.leftView as? UIImageView
        iconImage?.tintColor = .white
    }
    
    func endRefresher() {
        self.foodCollectionView.reloadData()
        let deadline = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToViewMenuScreen" {
            let destination = segue.destination as! ViewMenuViewController
            destination.foodId = selectedMenu
            if selectedMenuTag {
                destination.currentMenuTag = selectedMenuTag
                destination.currentIngredientsArr = selectedIngredients
                destination.currentIngredientsName = chosenName
            }
        }
    }
}

//MARK: SEARCHBAR

extension SearchViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArr = ingredientsArr.filter({$0.prefix(searchText.count) == searchText})
        searching = true
        ingredientsTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        iconImageView.isHidden = true
        statusLabel.isHidden = true
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        ingredientsTableView.isHidden = false
        searching = false
        
        ingredientsTableView.reloadData()
        
        searchBar.text = ""
        
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        ingredientsTableView.isHidden = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if menuData.isEmpty {
            iconImageView.isHidden = false
            statusLabel.isHidden = false
        }
        
        searchBar.text = ""
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        ingredientsTableView.isHidden = true
        searchByIngredients(chosenName: searchBar.text!)
        searchBar.text = ""
        self.view.endEditing(true)
    }
}

//MARK: FIREBASE

extension SearchViewController {
    
    func fetchSearchIngredients() {
        let ingDB = FirestoreReferenceManager.ingredientsDB
        ingDB.getDocument { (document, error) in
            if let error = error {
                print("something went wrong \(error)")
            } else {
                let dict = document?.data() as! [String:[String]]
                self.ingredientsDict = dict
                for (name, _) in dict {
                    self.ingredientsArr.append(name)
                    self.ingredientsTableView.reloadData()
                }
            }
            self.ingredientsArr.sort()
        }
    }
    
    @objc func searchByIngredients(chosenName: String) {
        searchedIngredients = chosenName
        menuData = []
        foodCollectionView.reloadData()
        
        let menuDB = FirestoreReferenceManager.menusDB
        menuDB.whereField("searchIngredients", arrayContains: chosenName).getDocuments { (query, error) in
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
                    let tag = "chosenName"
                    
                    let menuStruct = Menu(forSearch: name, id: foodId, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime, tag: tag)
                    
                    self.menuData.append(menuStruct)
                }
                if !self.ingredientsArr.contains(chosenName) {
                    print("end of searching")
                    self.endRefresher()
                    if self.menuData.isEmpty {
                        self.iconImageView.image = UIImage(named: "icon-sad")
                        self.statusLabel.text = "Sorry!\nwe could not find the menu\nwhich match with your ingredient."
                        self.iconImageView.isHidden = false
                        self.statusLabel.isHidden = false
                        print("check not contain")
                    }
                } else {
                    self.searchBySubstituteIngredients(chosenName: chosenName)
                }
            }
        }
        
        if !self.ingredientsArr.contains(chosenName) {
            return
        }
    }
    func searchBySubstituteIngredients(chosenName: String) {
        
        let menuDB = FirestoreReferenceManager.menusDB
        
        let chosenArr = ingredientsDict[chosenName]!
        
        if chosenArr.count > 10 {
            var target = 0
            var counter = 1
            if chosenArr.count % 10 == 0 {
                target = Int(chosenArr.count/10)
            } else {
                target = (Int(chosenArr.count/10) + 1)
            }
            for index in 1...target {
                var tempArr:[String] = []
                
                let firstIndex = (index - 1) * 10
                let finalIndex = firstIndex + 9
                
                if index == (Int(chosenArr.count/10) + 1) {
                    tempArr = Array(chosenArr[firstIndex..<chosenArr.count])
                } else {
                    tempArr = Array(chosenArr[firstIndex..<finalIndex])
                }
                
                menuDB.whereField("searchIngredients",arrayContainsAny: tempArr).getDocuments { (query, error) in
                    if let error = error {
                        print("Something went wrong \(error)")
                    } else {
                        counter += 1
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
                            let tag = "substitute"
                            
                            let menuStruct = Menu(forSearch: name, id: foodId, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime, tag: tag)
                            
                            self.menuData.append(menuStruct)
                            if counter == target && self.menuData.isEmpty {
                                print("1")
                                self.iconImageView.image = UIImage(named: "icon-sad")
                                self.statusLabel.text = "Sorry!\nwe could not find the menu\nwhich match with your ingredient."
                                self.iconImageView.isHidden = false
                                self.statusLabel.isHidden = false
                                print("check contain")
                            }
                        }
                        self.foodCollectionView.reloadData()
                    }
                    
                }
                
            }
            
        } else {
            menuDB.whereField("searchIngredients",arrayContainsAny: chosenArr).getDocuments { (query, error) in
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
                        let tag = "substitute"
                        
                        let menuStruct = Menu(forSearch: name, id: foodId, ownerName: ownerName, imageUrl: imageUrlString, estimatedTime: estimatedTime, rating: rating, served: served, createdTime: createdTime, tag: tag)
                        
                        self.menuData.append(menuStruct)
                    }
                    self.foodCollectionView.reloadData()
                    if self.menuData.isEmpty {
                        self.iconImageView.image = UIImage(named: "icon-sad")
                        self.statusLabel.text = "Sorry!\nwe could not find the menu\nwhich match with your ingredient."
                        self.iconImageView.isHidden = false
                        self.statusLabel.isHidden = false
                    }
                }
            }
        }

        self.endRefresher()
    }
}
//MARK: TABLEVIEW

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchArr.count
        } else {
            return ingredientsArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if searching {
            cell?.textLabel?.text = searchArr[indexPath.row]
        } else {
            cell?.textLabel?.text = ingredientsArr[indexPath.row]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chosenName = ""
        
        iconImageView.isHidden = true
        statusLabel.isHidden = true
        
        if searching {
            chosenName = searchArr[indexPath.row]
        } else {
            chosenName = ingredientsArr[indexPath.row]
        }
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.text = chosenName
        
        searchByIngredients(chosenName: chosenName)
        tableView.deselectRow(at: indexPath, animated: true)
        ingredientsTableView.isHidden = true
        self.view.endEditing(true)
    }
}

//MARK: COLLECTIONVIEW

extension SearchViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath) as! MenuCollectionViewCell
        
        let row = indexPath.row

        cell.substituteView.isHidden = true
        cell.substituteLabel.isHidden = true
        
        cell.foodNameLabel.text = menuData[row].name
        cell.ownerLabel.text = menuData[row].ownerName
        cell.ratingLabel.text = String(format:"%.1f(\(menuData[row].numberOfUserRated!))", menuData[row].averageRating!)
        cell.servedLabel.text = menuData[row].served
        cell.timeLabel.text = String(menuData[row].estimatedTime!) + "mins"
        cell.foodImageView.kf.setImage(with:menuData[row].imageUrl)
        
        if menuData[row].tag == "substitute" {
            let subsView = cell.substituteView!
            let subsText = cell.substituteLabel!
            subsView.isHidden = false
            subsText.isHidden = false
            subsView.layer.cornerRadius = 5
            subsText.text = "สามารถใช้\(searchedIngredients)แทนได้"
        }
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMenu = menuData[indexPath.row].foodId
        if menuData[indexPath.row].tag == "substitute" {
            selectedMenuTag = true
            selectedIngredients = ingredientsDict[chosenName]!
        }
        segueWithoutSender(destination: "goToViewMenuScreen")
    }
    
}

extension SearchViewController:UICollectionViewDelegateFlowLayout {
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 25
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 200)
    }
    
    func adjustCellPadding() {
        let layout = self.foodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
    }
}
