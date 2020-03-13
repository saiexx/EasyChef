//
//  ProfileImageTableViewCell.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 8/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

protocol ProfileImageTableViewCellDelegate {
    func cameraButtonPressed()
}

class ProfileImageTableViewCell: UITableViewCell {
    
    var delegate: ProfileImageTableViewCellDelegate?

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        delegate?.cameraButtonPressed()
    }

}
