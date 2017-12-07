//
//  FollowService.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 4/12/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        let ref = Database.database().reference().child("followers")
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            // 1
            UserService.posts(for: user) { (posts) in
                // 2
                let postKeys = posts.flatMap { $0.key }
                
                // 3
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                // 4
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // 5
                    success(error == nil)
                })
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            // 1
            UserService.posts(for: user) { (posts) in
                // 2
                let postKeys = posts.flatMap { $0.key }
                
                // 3
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                // 4
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // 5
                    success(error == nil)
                })
            }
        }
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("followers").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
}

