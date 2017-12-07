//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 30/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit

class PostHeaderCell : UITableViewCell {
    
    var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
    
    static let height : CGFloat = 54
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        if let closure = didTapOptionsButtonForCell {
            closure(self)
        }
    }
}

