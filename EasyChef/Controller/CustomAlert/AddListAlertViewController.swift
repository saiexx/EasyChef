//
//  AddListAlertViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

class AddListAlertViewController: UIViewController {

    @IBOutlet weak var listTextField: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var buttonAction: ((String) -> Void)?
    var changeCase:String?
    var titleText:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.isHidden = true
        
        checkCase()
        
        listTextField.placeholder = "New List"
        
        alertView.layer.cornerRadius = 10
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = UIColor.gray.cgColor
        alertView.clipsToBounds = true
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        guard let listText = listTextField.text, !listTextField.text!.isEmpty else {
            warningLabel.isHidden = false
            return
        }
        
        self.dismiss(animated: true)
        
        buttonAction?(listText)
    }
    func checkCase() {
        switch changeCase {
        case "add":
            addButton.setTitle("Add", for: .normal)
            titleLabel.text = "Name Your New List"
        case "rename":
            addButton.setTitle("Rename", for: .normal)
            titleLabel.text = "Rename Your List"
        default:
            print("error action not found")
        }
    }
    
}
