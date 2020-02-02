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
    
    var buttonAction: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.dismiss(animated: true)
        guard let listText = listTextField.text, !listTextField.text!.isEmpty else {
            print("Fill information")
            return
        }
        
        buttonAction?(listText)
    }
    
}
