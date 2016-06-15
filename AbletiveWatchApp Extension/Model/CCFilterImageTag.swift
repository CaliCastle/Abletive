//
//  CCFilterImageTag.swift
//  Abletive
//
//  Created by Cali Castle on 3/4/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CCFilterImageTag: NSObject {
    static func filter(_ html : NSString) -> NSString? {
        var fullAvatarPath = html;
        // Get the img src
    
        if fullAvatarPath.contains("img src") {
            var range = fullAvatarPath.range(of: "\"")
            fullAvatarPath = fullAvatarPath.substring(from: range.location+1)
            range = fullAvatarPath.range(of: "\"")
            fullAvatarPath = fullAvatarPath.substring(to: range.location)
        }
        // Decode the string to url standard
        let characterSet = CharacterSet(charactersIn: fullAvatarPath as String);
        return fullAvatarPath.addingPercentEncoding(withAllowedCharacters: characterSet)!;
    }
}
