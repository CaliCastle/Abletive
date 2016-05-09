//
//  Testimonial.swift
//  Abletive
//
//  Created by Cali Castle on 3/3/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class Testimonial: NSObject {
    var avatar = ""
    var name = ""
    var caption = ""
    var message = ""
    
    init(attributes: NSDictionary) {
        avatar = attributes["avatar"] as! String
        name = attributes["name"] as! String
        caption = attributes["caption"] as! String
        message = attributes["message"] as! String
    }
}
