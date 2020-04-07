//
//  ReviewButtonTableViewCell.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 7/4/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

protocol ReviewButtonTableViewCellDelegate {
    
    func ReviewButtonPressed()
}

class ReviewButtonTableViewCell: UITableViewCell {
    
    var delegate: ReviewButtonTableViewCellDelegate?

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var reviewButton: UIButton!
    
    
    @IBAction func reviewButtonPressed(_ sender: Any) {
        delegate?.ReviewButtonPressed()
    }
    
}
