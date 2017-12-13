//
//  MainTabBarController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 30/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let photoHelper = MGPhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoHelper.completionHandler = { image in
            PostService.create(for: image)
        }
        
        delegate = self
        tabBar.unselectedItemTintColor = .black
        
    }
}
extension MainTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.tabBarItem.tag == 1 {
            photoHelper.presentActionSheet(from: self)
            print("take photo")
            return false
        }
        return true
    }
}
