//
//  CreateMenuViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 21/4/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

class CreateMenuViewController: UIViewController {
    
    @IBOutlet var describeTextField: [UITextField]!
    @IBOutlet var addButton: [UIButton]!
    @IBOutlet var deleteButton: [UIButton]!
    
    @IBOutlet weak var ingredientsTableView: SelfSizedTableView!
    @IBOutlet weak var directionsTableView: SelfSizedTableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var foodImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertIngredientLabel: UILabel!
    @IBOutlet weak var alertDirectionLabel: UILabel!
    
    var checker:Bool = true
    
    var numOfIngredients:Int = 3
    var numOfDirections:Int = 3
    
    var name:String?
    var serving:String?
    var estimatedTime:Int?
    
    var ingredients:[String:[String:String]] = [:]
    var directions:[String:String] = [:]
    
    var searchIngredients:[String] = []
    
    var image:UIImage?
    
    var editStatus:Bool = false
    
    var currentMenu: Menu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editStatus {
            setupForEdit()
        }
        setupView()
        setupTableView()
    }
    
    func setupView() {
        for textField in describeTextField {
            textField.layer.cornerRadius = 5
            textField.setLeftPaddingPoints(5)
            textField.setRightPaddingPoints(5)
        }
        
        for button in addButton {
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func setupForEdit() {
        name = currentMenu.name
        serving = currentMenu.served
        estimatedTime = currentMenu.estimatedTime
        
        ingredients = currentMenu.ingredients
        directions = currentMenu.method
        
        foodImageView.kf.setImage(with: currentMenu.imageUrl)
        numOfIngredients = ingredients.count
        numOfDirections = directions.count
        
        titleLabel.text = "Edit"
        
        describeTextField[0].text = name
        describeTextField[1].text = serving
        describeTextField[2].text = "\(estimatedTime!)"
    }
    
    @IBAction func deleteLastRowButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            if numOfIngredients == 1 {
                return
            }
            ingredients.removeValue(forKey: "\(numOfIngredients)")
            numOfIngredients -= 1
            let indexPath = IndexPath(row: numOfIngredients, section: 0)
            let cell = ingredientsTableView.cellForRow(at: indexPath) as! AddIngredientsTableViewCell
            cell.amountTextField.text = ""
            cell.nameTextField.text = ""
            
            ingredientsTableView.reloadData()
        }
        if sender.tag == 1 {
            if numOfDirections == 1 {
                return
            }
            directions.removeValue(forKey: "\(numOfDirections)")
            numOfDirections -= 1
            let indexPath = IndexPath(row: numOfDirections, section: 0)
            let cell = directionsTableView.cellForRow(at: indexPath) as! AddDirectionsTableViewCell
            
            cell.directionTextField.text = ""
            directionsTableView.reloadData()
        }
    }
    
    
    func setupTableView() {
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        
        ingredientsTableView.separatorColor = UIColor.clear
        ingredientsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        directionsTableView.dataSource = self
        directionsTableView.delegate = self
        
        directionsTableView.separatorColor = UIColor.clear
        directionsTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    @IBAction func NextButtonPressed(_ sender: Any) {
        
        name = describeTextField[0].text!
        serving = describeTextField[1].text!
        estimatedTime = Int(describeTextField[2].text!)
        
        alertNameLabel.isHidden = true
        alertDirectionLabel.isHidden = true
        alertIngredientLabel.isHidden = true
        
        checker = true
        
        if name == "" {
            alertNameLabel.isHidden = false
            return
        }
        
        getIngredients()
        getDirections()
        
        if checker {
            segueWithoutSender(destination: "toPreviewScreen")
        }
    }
    
    func getIngredients(){
        var tempDict:[String:[String:String]] = [:]
        
        for number in 0 ..< numOfIngredients {
            let indexPath = IndexPath(row: number, section: 0)
            let cell = ingredientsTableView.cellForRow(at: indexPath) as! AddIngredientsTableViewCell
            let name = cell.nameTextField.text!
            let amount = cell.amountTextField.text!
            
            if name == "" {
                alertIngredientLabel.isHidden = false
                checker = false
                return
            }
            
            tempDict["\(number + 1)"] = ["name":name, "amount":amount]
            searchIngredients.append(name)
        }
        
        ingredients = tempDict
    }
    
    func getDirections() {
        var tempDict:[String:String] = [:]
        
        for number in 0 ..< numOfDirections {
            let indexPath = IndexPath(row: number, section: 0)
            let cell = directionsTableView.cellForRow(at: indexPath) as! AddDirectionsTableViewCell
            let name = cell.directionTextField.text!
            
            if name == "" {
                alertDirectionLabel.isHidden = false
                checker = false
                return
            }
            
            tempDict["\(number + 1)"] = name
        }
        
        directions = tempDict
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddCellButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            numOfIngredients += 1
            ingredientsTableView.reloadData()
        }
        if sender.tag == 1 {
            numOfDirections += 1
            directionsTableView.reloadData()
        }
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: Any) {
        displayImagePickerControllerActionSheet()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPreviewScreen" {
            let destinationVC = segue.destination as! PreviewViewController
            
            destinationVC.name = name
            destinationVC.serving = serving
            destinationVC.estimatedTime = estimatedTime
            destinationVC.ingredientsDict = ingredients
            destinationVC.directionsDict = directions
            destinationVC.image = foodImageView.image!
            destinationVC.editStatus = editStatus
            destinationVC.ingredientsArr = searchIngredients
            if editStatus {
                destinationVC.foodId = currentMenu.foodId
            }
        }
    }
}

//MARK: TABLEVIEW
extension CreateMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == ingredientsTableView {
            return numOfIngredients
        }
        if tableView == directionsTableView {
            return numOfDirections
        }
        
        return Int()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == ingredientsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Ingredient", for: indexPath) as! AddIngredientsTableViewCell
            cell.contentBackgroundView.layer.cornerRadius = 5
            
            let row = indexPath.row + 1
            if editStatus && row <= ingredients.count {
                cell.nameTextField.text = ingredients["\(row)"]!["name"]
                cell.amountTextField.text = ingredients["\(row)"]!["amount"]
            }
            cell.selectionStyle = .none
            
            return cell
        }
        if tableView == directionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Direction", for: indexPath) as! AddDirectionsTableViewCell
            cell.contentBackgroundView.layer.cornerRadius = 5
            cell.numberLabel.text = "\(indexPath.row + 1)"
            
            let row = indexPath.row + 1
            if editStatus && row <= directions.count {
                cell.directionTextField.text = directions["\(row)"]
            }
            
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }

}

extension CreateMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func displayImagePickerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (action) in
            self.showImagePicker(sourceType: .photoLibrary)
        })
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.showImagePicker(sourceType: .camera)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        foodImageView.image = image!
        picker.dismiss(animated: true, completion: nil)
    }
}
