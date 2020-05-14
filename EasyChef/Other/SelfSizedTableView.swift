//
//  SelfSizedTableView.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/5/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

class SelfSizedTableView: UITableView {

    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
      
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        
        self.layoutIfNeeded()
    }
      
    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
