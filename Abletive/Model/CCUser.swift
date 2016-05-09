//
//  CCUser.swift
//  Abletive
//
//  Created by Cali Castle on 3/2/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CCUser: NSObject {
    var identifier : UInt = 0
    var user_identifier : UInt = 0
    var name = ""
    var display_name = ""
    var email = ""
    var expired_at = ""
    var experience = "0"
    var role = "Member"
    var avatar = ""
    var registered_at = ""
    var descrip = ""
    var slug : String?
    
    init(attributes : NSDictionary) {
        identifier = attributes["id"] as! UInt
        user_identifier = attributes["user_id"] as! UInt
        name = attributes["name"] as! String
        display_name = attributes["display_name"] as! String
        email = attributes["email"] as! String
        expired_at = attributes["expired_at"] as! String
        experience = attributes["experience"] as! String
        role = attributes["role"] as! String
        avatar = attributes["avatar"] as! String
        registered_at = attributes["registered_at"] as! String
        descrip = attributes["description"] as! String
        slug = attributes["slug"] as? String
    }
}
