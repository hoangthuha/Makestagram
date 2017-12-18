//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 29/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI
typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let authUI = FUIAuth.defaultAuthUI()
            else {return }
        authUI.delegate = self
        
        let providers: [FUIAuthProvider] = [FUIFacebookAuth(), FUIGoogleAuth()]
        authUI.providers = providers
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
}
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        
        if let error = error {
            let alertVC = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        UserService.show(forUID: (user?.uid)!) { (user) in
            if let user = user {
                //handle existing user
                User.setCurrent(user, writeToUserDefaults: true)
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                print("Welcome back, \(user.username).")
            } else {
                //handle new user
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        }
    }
}
