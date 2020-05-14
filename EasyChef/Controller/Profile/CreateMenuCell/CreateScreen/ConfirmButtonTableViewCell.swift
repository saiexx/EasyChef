//
//  ConfirmButtonTableViewCell.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 3/5/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
protocol ConfirmButtonTableViewCellDelegate {
    
    func editButtonPressed()
    func confirmButtonPressed()
    
}

class ConfirmButtonTableViewCell: UITableViewCell {
    
    var delegate: ConfirmButtonTableViewCellDelegate?
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBAction func editButtonPressed(_ sender: Any) {
        delegate?.editButtonPressed()
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        delegate?.confirmButtonPressed()
    }
    
}
