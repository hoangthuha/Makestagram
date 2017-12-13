//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 29/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return}
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user
                else { return }
            User.setCurrent(user, writeToUserDefaults: true)
            
            FollowService.setIsFollowing(true, fromCurrentUserTo: User.current!, success: { (success) in
                if success {
                    let initialViewController = UIStoryboard.initialViewController(for: .main)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                } else {
                    fatalError()
                }
            })
            
            print("Create new user: \(user.username)")
        }
    }
}

