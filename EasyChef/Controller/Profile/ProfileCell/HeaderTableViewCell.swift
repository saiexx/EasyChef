//
//  HeaderTableViewCell.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 6/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

protocol HeaderTableViewCellDelegate {
    
    func profileButtonPressed()
}

class HeaderTableViewCell: UITableViewCell {

    var delegate: HeaderTableViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        delegate?.profileButtonPressed()
    }
}
