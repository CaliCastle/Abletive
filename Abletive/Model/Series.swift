//
//  Series.swift
//  Abletive
//
//  Created by Cali Castle on 3/1/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class Series: NSObject {
    
    var identifier : UInt = 0
    var title : String = ""
    var difficulty : String = ""
    var thumbnail : String = ""
    var slug : String = ""
    var completed : Bool = false
    var published : Bool = false
    var descrip : String = ""
    var skill : String = ""
    var created_at : String = ""
    var updated_at : String = ""
    var episodes : UInt = 0
    
    var recentlyPublished : Bool = false
    var recentlyUpdated : Bool = false
    
    init(attributes : NSDictionary) {
        identifier = attributes["id"] as! UInt
        title = attributes["title"] as! String
        thumbnail = attributes["thumbnail"] as! String
        slug = attributes["slug"] as! String
        completed = attributes["completed"] as! UInt == 1
        published = attributes["published"] as! UInt == 1
//        skill = Skill.map[attributes["skill_id"] as! Int]!
        descrip = attributes["description"] as! String
        created_at = attributes["created_at"] as! String
        updated_at = attributes["updated_at"] as! String
        episodes = attributes["episodes"] as! UInt
        
        recentlyPublished = attributes["recently_published"] as! UInt == 1
        recentlyUpdated = attributes["recently_updated"] as! UInt == 1
        
        switch attributes["difficulty"] as! String {
            case "Beginner":
                difficulty = "初级"
                break;
            case "Intermediate":
                difficulty = "中级"
                break;
            default:
                difficulty = "高级"
                break;
        }
        
    }
    
    static func getIndexSeries(_ callback: @escaping ([Series]?, NSError?) -> Void) {
//        AbletiveAPIClient.sharedScreenCast().get("index", parameters: ["_passphrase" : AbletivePassphrase], success: { (dataTask, response) -> Void in
//            let JSON = response as! NSDictionary
//            print(JSON)
//            }) { (dataTask, error) -> Void in
//                callback(nil, error)
//        }
    }
    
}
