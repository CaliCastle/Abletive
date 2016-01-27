//
//  ExtensionDelegate.swift
//  AbletiveWatchApp Extension
//
//  Created by Cali Castle on 1/13/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {

    let kCheckInKey = "Apple_Watch_Check_In_Enabled"
    let kPostCountKey = "Apple_Watch_Post_Count"
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if message[kCheckInKey] != nil {
            
        } else if message[kPostCountKey] != nil {
            
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
