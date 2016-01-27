//
//  AppConfiguration.swift
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

public class AppConfiguration : NSObject {

    private struct Bundle {
        static var identifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        static let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        static let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    public struct UserActivity {
        static let payment = "\(Bundle.identifier).payment"
    }
    
    public struct Merchant {
        static let identifier = "merchant.\(Bundle.identifier)"
    }
    
    public static let identifier : String = Bundle.identifier
    public static let versionNumber : String = Bundle.version
    public static let buildNumber : String = Bundle.buildNumber
    public static let userActivityPayment : String = UserActivity.payment
    public static let merchantIdentifier : String = Merchant.identifier
    
}
