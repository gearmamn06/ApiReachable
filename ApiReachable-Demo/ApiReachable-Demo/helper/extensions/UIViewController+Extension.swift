//
//  UIViewController+Extension.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 21/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

extension UIViewController: SelfNamable {}


extension SelfNamable where Self: UIViewController {
    
    static var instance: Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: self.name) as! Self
    }
}


extension UIViewController {
    
    
    func showErrorAlert(title: String? = nil, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}


