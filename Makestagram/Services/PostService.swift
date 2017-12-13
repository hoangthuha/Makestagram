//
//  PostService.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 30/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    static func flag(_ post: Post) {
        guard let postKey = post.key else { return }
        let flaggedPostRef = Database.database().reference().child("flaggedPosts").child(postKey)
        let flaggedDict = ["image_url": post.imageURL,
                           "poster_uid": post.poster.uid,
                           "reporter_uid": User.current!.uid]
        
        flaggedPostRef.updateChildValues(flaggedDict)
        
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            
            mutableData.value = currentCount + 1
            
            return TransactionResult.success(withValue: mutableData)
        })
    }
    
    static func create(for image : UIImage) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else { return}
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(forURLString: urlString, aspectHeight: aspectHeight)
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
    private static func create (forURLString urlString : String, aspectHeight : CGFloat) {
        let currentUser = User.current!
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        let dict = post.dictValue
        let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        postRef.updateChildValues(dict)
        
        Database.database().reference().child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let user = User.init(snapshot: snapshot) {
                user.postCount = user.postCount! + 1
                Database.database().reference().child("users").child(currentUser.uid).updateChildValues(user.dictValue)
                User.setCurrent(user)
                User.postCountChange()
            }
        }
        
    }
}
