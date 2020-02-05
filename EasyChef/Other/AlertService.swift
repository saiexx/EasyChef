//
//  AlertService.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit

class AlertService {
    func addListAlert(for action:String, completion: @escaping (String) -> Void) -> AddListAlertViewController {
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AddListVC") as! AddListAlertViewController
        
        alertVC.buttonAction = completion
        alertVC.changeCase = action
        
        return alertVC
    }
}

