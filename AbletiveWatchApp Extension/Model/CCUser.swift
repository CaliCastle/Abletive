//
//  CCUser.swift
//  Abletive
//
//  Created by Cali Castle on 1/14/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import Foundation

public class CCUser : NSObject {
    
    var userName : String?
    var userID : String?
    var userFollowing : String?
    var userFollowers : String?
    var avatarURL : String?
    var memberDays : UInt?
    
    // MARK : More Info
    var postCount : UInt?
    var commentCount : UInt?
    var credit : UInt?
    var membership : String?
    
    override init() {
        
    }
    
    init(attributes : NSDictionary) {
        userName = attributes["user_info"]!["display_name"] as? String
        userID = attributes["user_info"]!["ID"] as? String
        userFollowing = attributes["following_count"] as? String
        userFollowers = attributes["follower_count"] as? String
        avatarURL = attributes["avatar"] as? String
        memberDays = attributes["registered_days"] as? UInt
        
        postCount = attributes["posts_count"] as? UInt
        commentCount = attributes["comments_count"] as? UInt
        credit = attributes["credit"] as? UInt
        membership = attributes["membership"]!["user_type"] as? String
    }
}