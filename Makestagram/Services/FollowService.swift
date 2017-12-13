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
        let currentUID = User.current!.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                success(true)
                Database.database().reference().child("users").child(currentUID).observeSingleEvent(of: .value) { (following) in
                    if let user = User.init(snapshot: following) {
                        if currentUID != user.uid {
                            user.followingCount = user.followingCount! + 1
                        }
                        Database.database().reference().child("users").child(currentUID).updateChildValues(user.dictValue)
                        User.setCurrent(user)
                        User.followingCountChange()
                    }
                }
                Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value) { (following) in
                    if let user = User.init(snapshot: following) {
                        
                        if currentUID != user.uid {
                            user.followerCount = user.followerCount! + 1
                        }
                        Database.database().reference().child("users").child(user.uid).updateChildValues(user.dictValue)
                    }
                }
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current!.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                success(true)
                Database.database().reference().child("users").child(currentUID).observeSingleEvent(of: .value) { (following) in
                    if let user = User.init(snapshot: following) {
                        if user.followingCount! > 0 {
                            user.followingCount = user.followingCount! - 1
                            Database.database().reference().child("users").child(currentUID).updateChildValues(user.dictValue)
                            User.setCurrent(user)
                            User.followingCountChange()
                        }
                    }
                }
                Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value) { (following) in
                    if let user = User.init(snapshot: following) {
                        user.followingCount = user.followerCount! - 1
                        Database.database().reference().child("users").child(user.uid).updateChildValues(user.dictValue)
                    }
                }
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
        let currentUID = User.current!.uid
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

