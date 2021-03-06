//
//  PhotoViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 14/12/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController : UIViewController{

    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var detailImage: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update(post)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        if post.likeCount > 0 {
            likeButton.setImage(UIImage(named:"redheart"), for: .selected)
        }
    }
    
    
    //MARK: - ConfigData
    
    func update(_ post: Post) {
        self.usernameLabel.text = User.current?.username ?? "Test"
        if post.likeCount > 1 {
            self.likeLabel.text =  "\(post.likeCount) likes"
        }
        else {
            self.likeLabel.text = "\(post.likeCount) like"
        }
        let imageURL = URL(string: post.imageURL)
        self.detailImage.kf.setImage(with: imageURL)
        
    }
}
