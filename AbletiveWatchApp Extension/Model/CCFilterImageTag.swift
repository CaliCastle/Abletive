//
//  CCFilterImageTag.swift
//  Abletive
//
//  Created by Cali Castle on 3/4/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CCFilterImageTag: NSObject {
    static func filter(html : NSString) -> NSString? {
        var fullAvatarPath = html;
        // Get the img src
    
        if fullAvatarPath.containsString("img src") {
            var range = fullAvatarPath.rangeOfString("\"")
            fullAvatarPath = fullAvatarPath.substringFromIndex(range.location+1)
            range = fullAvatarPath.rangeOfString("\"")
            fullAvatarPath = fullAvatarPath.substringToIndex(range.location)
        }
        // Decode the string to url standard
        let characterSet = NSCharacterSet(charactersInString: fullAvatarPath as String);
        return fullAvatarPath.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!;
    }
}
