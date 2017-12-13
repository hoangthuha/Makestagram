//
//  User.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 29/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

enum UserKeys : String {
    case followerCount = "follower_count"
    case followingCount = "following_count"
    case postCount = "post_count"
    case isFollowed = "is_followed"
    case uid = "uid"
    case username = "username"
}

let kPostCountNotification = "kPostCountNotification"
let kFollowingCountNotification = "kFollowingCountNotification"

class User {
    
    var followerCount: Int?
    var followingCount: Int?
    var postCount: Int?
    var isFollowed = false
    let uid : String
    let username : String
    
    var dictValue: [String : Any] {
        let postDict : [String : Any] = ["uid" : uid,
                        "username" : username,
                        "follower_count" : followerCount ?? 0,
                        "following_count" : followingCount ?? 0,
                        "post_count" : postCount ?? 0]
        
        return postDict
    }
    
    private static var _current: User?
    
    static var current: User? {
        guard let currentUser = _current else {
            guard let uid = self.userDef.string(forKey: UserKeys.uid.rawValue), let username = self.userDef.string(forKey: UserKeys.username.rawValue) else { return nil }
            
            let followerCount = self.userDef.integer(forKey: UserKeys.followerCount.rawValue)
            let followingCount = self.userDef.integer(forKey: UserKeys.followingCount.rawValue)
            let postCount = self.userDef.integer(forKey: UserKeys.postCount.rawValue)
            let isFollowed = self.userDef.bool(forKey: UserKeys.isFollowed.rawValue)
            
            let user = User(username: username, uid: uid)
            user.followerCount = followerCount
            user.followingCount = followingCount
            user.postCount = postCount
            user.isFollowed = isFollowed
            
            return user
        }
        
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            self.userDef.set(user.followerCount, forKey: UserKeys.followerCount.rawValue)
            self.userDef.set(user.followingCount, forKey: UserKeys.followingCount.rawValue)
            self.userDef.set(user.postCount, forKey: UserKeys.postCount.rawValue)
            self.userDef.set(user.isFollowed, forKey: UserKeys.isFollowed.rawValue)
            self.userDef.set(user.uid, forKey: UserKeys.uid.rawValue)
            self.userDef.set(user.username, forKey: UserKeys.username.rawValue)
        }
        _current = user
    }
    
    static func postCountChange() {
        NotificationCenter.default.post(name: NSNotification.Name.init(kPostCountNotification), object: User.current?.postCount)
    }
    
    static func followingCountChange() {
        NotificationCenter.default.post(name: NSNotification.Name.init(kFollowingCountNotification), object: User.current?.followingCount)
    }
    
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let followerCount = dict["follower_count"] as? Int,
            let followingCount = dict["following_count"] as? Int,
            let postCount = dict["post_count"] as? Int
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount        
    }
    
    init(username: String, uid: String) {
        self.username = username
        self.uid = uid
    }
    
    private static let userDef = UserDefaults.standard
}

