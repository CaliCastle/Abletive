//
//  Inbox.swift
//  Abletive
//
//  Created by Cali Castle on 3/18/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class Inbox: NSObject {
    var content = ""
    var status = ""
    var date = ""
    var url = ""
    
    init(attribute : Dictionary<String, AnyObject>) {
        content = attribute["content"] as! String
        status = attribute["type"] as! String
        date = attribute["date"] as! String
        
        let urls = attribute["url"] as! NSArray
        url = urls.firstObject as! String
    }
    
    class func getInboxMessages(_ page : Int, count : Int, callback : ([Inbox]?, NSError?) -> Void) {
        let user = UserDefaults.standard().dictionary(forKey: "user")!
        let user_id = user["id"] as! Int
        AbletiveAPIClient.shared().get("user/get_inbox", parameters: ["page" : page, "count" : count, "user_id" : user_id], success: { (dataTask, response) in
            let JSON = response as! NSDictionary
            if JSON["status"] as! String == "ok" {
                let messagesList = JSON["messages"] as! NSArray
                var inboxes = [Inbox]()
                for i in 0..<messagesList.count {
                    let inbox = Inbox(attribute: messagesList.object(at: i) as! Dictionary<String, AnyObject>)
                    inboxes.append(inbox)
                }
                callback(inboxes, nil)
            } else {
                callback(nil, NSError(domain: "", code: 1, userInfo: nil))
            }
            }) { (dataTask, error) in
                print(error)
                callback(nil, error)
        }
    }
}
