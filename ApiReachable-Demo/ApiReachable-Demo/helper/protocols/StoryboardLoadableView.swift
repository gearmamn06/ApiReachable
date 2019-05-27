//
//  StoryboardLoadableView.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 21/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


protocol StoryboardLoadableView {
    
    var storyboardName: String { get }
}

extension StoryboardLoadableView {
    
    static var storyboardName: String {
        return "Main"
    }
}



extension StoryboardLoadableView where Self: UIViewController {
    
    static var instance: Self {
        let storyBoard = UIStoryboard(name: self.storyboardName, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: self.name) as! Self
    }
}
