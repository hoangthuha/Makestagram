//
//  StorageReference+Post.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 30/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import Foundation
import FirebaseStorage


extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostImageReference() -> StorageReference {
        let uid = User.current!.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
}
