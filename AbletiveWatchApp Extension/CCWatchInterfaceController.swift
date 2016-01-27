//
//  CCWatchInterfaceController.swift
//  Abletive
//
//  Created by Cali Castle on 1/13/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class CCWatchInterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var checkInButton: WKInterfaceButton!
    @IBOutlet var followingLabel: WKInterfaceLabel!
    @IBOutlet var followerLabel: WKInterfaceLabel!
    @IBOutlet var avatarImage: WKInterfaceImage!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var daysDescLabel: WKInterfaceLabel!
    @IBOutlet var daysLabel: WKInterfaceLabel!
    @IBOutlet var moreInfoGroup: WKInterfaceGroup!
    @IBOutlet var postCountLabel: WKInterfaceLabel!
    @IBOutlet var commentCountLabel: WKInterfaceLabel!
    @IBOutlet var creditLabel: WKInterfaceLabel!
    @IBOutlet var membershipLabel: WKInterfaceLabel!
    
    var userID : String?
    var loggedIn : Bool = false
    var currentUser : CCUser?
    var userDesc : String?
    
    let kSettingKey = "Settings_Changed"
    let kCheckInKey = "CheckIn"
    let kPostCountKey = "PostCount"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let defaults = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? NSDictionary {
            userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
            currentUser = CCUser(attributes: defaults)
            loggedIn = true
        } else {
            currentUser = CCUser()
        }
        updateViews()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // If the WC is supported, activate it
        if WCSession.isSupported() && WCSession.defaultSession().reachable {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            fetchUserFromiPhone(session)
        }
    }
    
    func fetchUserFromiPhone(session : WCSession = WCSession.defaultSession()) {
        // Send a message to the iOS container app, if we don't have any defaults
        session.sendMessage(["fetchUserDefaults":"1"], replyHandler: { (replies:Dictionary?) -> Void in
            // If the user is logged in
            print(replies)
            if replies!["hasSignedIn"] as! Int == 1 {
                let userDefaults : Dictionary = replies!
                self.userDesc = userDefaults["description"] as? String
                self.loggedIn = true
                self.currentUser?.avatarURL = userDefaults["avatar"] as? String
                
                self.updateViews()
                self.getUserInformation(String(userDefaults["id"] as! UInt))
                
            } else {
                // The user is not logged in
                self.updateViews()
            }
            
            }, errorHandler: { (error) -> Void in
                // Error handler
                self.showErrorOverlay("与iPhone连接超时", retryable: true)
        })
    }
    
    func getUserInformation(userID : String?){
        
        if userID == nil || userID == "0" {
            showErrorOverlay("用户不存在", retryable: false)
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(userID!, forKey: "userID")
        
        let request = NSURLRequest(URL: NSURL(string: "http://abletive.com/api/user/get_personal_page_detail/?user_id=\(userID!)")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error == nil {
                // Request succeeded
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    NSUserDefaults.standardUserDefaults().setObject(JSON, forKey: "userInfo")

                    self.currentUser = CCUser(attributes: JSON as! NSDictionary)

                    self.updateViews()
                }
                catch _{
                    print("Something went wrong when making the JSON Object")
                    self.showErrorOverlay()
                }
            } else {
                // Request failed
                self.showErrorOverlay()
            }
        }.resume()
        
    }
    
    func updateViews() {
        if NSUserDefaults.standardUserDefaults().objectForKey(kCheckInKey) != nil {
            if loggedIn {
                checkInButton.setHidden(!NSUserDefaults.standardUserDefaults().boolForKey(kCheckInKey))
            } else {
                checkInButton.setHidden(true)
            }
        } else {
            checkInButton.setHidden(!loggedIn)
        }
        
        nameLabel.setText(loggedIn ? currentUser?.userName : "请在iPhone登录")
        descriptionLabel.setText(loggedIn ? userDesc : "")
        daysDescLabel.setHidden(!loggedIn)
        daysLabel.setHidden(!loggedIn)
        moreInfoGroup.setHidden(!loggedIn)
        
        if loggedIn {
            if currentUser?.avatarURL != "" {
                ImageLoader.sharedLoader.imageForUrl((currentUser?.avatarURL)!, completionHandler: { (image, url) -> () in
                    self.avatarImage.setImage(image)
                })
            }
            if currentUser?.userFollowing != nil {
                followingLabel.setText(currentUser?.userFollowing!)
                followerLabel.setText(currentUser?.userFollowers!)
                daysLabel.setText("\((currentUser?.memberDays)! as UInt)天了")
                postCountLabel.setText("\((currentUser?.postCount)! as UInt)篇")
                commentCountLabel.setText("\((currentUser?.commentCount)! as UInt)次")
                creditLabel.setText("\((currentUser?.credit)! as UInt)")
                membershipLabel.setText(currentUser?.membership)
            }
            
        } else {
            avatarImage.setImageNamed("watch-avatar")
            followerLabel.setText("0")
            followingLabel.setText("0")
        }
    }
    
    func showErrorOverlay(text : String = "请求出错，请重试", retryable : Bool = true) {
        let okAction = WKAlertAction(title: "知道了", style: .Default) { () -> Void in
            
        }
        if (retryable) {
            let retryAction = WKAlertAction(title: "重试", style: .Destructive) { () -> Void in
                self.getUserInformation(self.userID!)
            }
            presentAlertControllerWithTitle("出错啦", message: text, preferredStyle: .SideBySideButtonsAlert, actions: [okAction,retryAction])
        }
        presentAlertControllerWithTitle("出错啦", message: text, preferredStyle: .Alert, actions: [okAction])
        WKInterfaceDevice.currentDevice().playHaptic(.Retry)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func checkInDidTap() {
        // Send check in message
        if WCSession.isSupported() && loggedIn && WCSession.defaultSession().reachable {
            checkInButton.setEnabled(false)
            checkInButton.setTitle("签到中...")
            WKInterfaceDevice.currentDevice().playHaptic(.Start)
            
            let session = WCSession.defaultSession()
            
            session.sendMessage(["checkIn" : "1"], replyHandler: { (replies : Dictionary?) -> Void in
                let message = replies!["message"] as! String
                
                let action = WKAlertAction(title: "OK", style: .Default, handler: { () -> Void in
                    
                })
                
                let checkedIn : Bool = (replies!["status"] as! String == "ok")
                self.presentAlertControllerWithTitle(checkedIn ? "签到成功" : "签到失败" , message: message, preferredStyle: .Alert, actions: [action])
                
                self.checkInButton.setEnabled(!checkedIn)
                self.checkInButton.setTitle("已签到")
                WKInterfaceDevice.currentDevice().playHaptic(.Success)
                
                }, errorHandler: { (error) -> Void in
                    self.checkInButton.setEnabled(true)
                    self.checkInButton.setTitle("签到")
                    WKInterfaceDevice.currentDevice().playHaptic(.Failure)
            })
        } else {
            showErrorOverlay("请先在iPhone上登录", retryable: false)
            WKInterfaceDevice.currentDevice().playHaptic(.Failure)
        }
    }
    
    @IBAction func qrCodeButtonDidTap() {
        // Load QRCode
        // Send check in message
        if WCSession.isSupported() && loggedIn && WCSession.defaultSession().reachable {
            let session = WCSession.defaultSession()
            WKInterfaceDevice.currentDevice().playHaptic(.Success)
            session.sendMessage(["fetchQRCode":"1"], replyHandler: { (replies : Dictionary?) -> Void in
                let qrImageData = replies!["image"] as! NSData
                
                self.presentControllerWithName("QRCode", context: qrImageData)
                
                }, errorHandler: { (error) -> Void in
                    self.showErrorOverlay("请在iPhone上打开应用", retryable: true)
            })
        } else {
            showErrorOverlay("请先在iPhone上登录", retryable: false)
        }
    }
    
    @IBAction func refreshDidTap() {
        // Refresh everything we got here
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
        ImageLoader.sharedLoader.cache.removeAllObjects()
        fetchUserFromiPhone()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if message["userLoggedIn"] != nil {
            // User has logged in
            currentUser = CCUser()
        
            let userInfo = message["userInfo"] as? NSDictionary
            userID = String(userInfo!["id"] as! UInt)
            self.userDesc = userInfo!["description"] as? String
            self.currentUser?.avatarURL = userInfo!["public_info"]!["avatar"] as? String
            
            updateViews()
            
            getUserInformation(userID!)
            loggedIn = true
        } else if message["userLoggedOut"] != nil {
            // User has logged out
            loggedIn = false
            NSUserDefaults.standardUserDefaults().removeObjectForKey("userInfo")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("userID")
            updateViews()
        } else if message[kSettingKey] != nil {
            NSUserDefaults.standardUserDefaults().setInteger(Int(message[kPostCountKey] as! String)!, forKey: kPostCountKey)
            NSUserDefaults.standardUserDefaults().setBool((message[kCheckInKey] as! Int) == 1, forKey: kCheckInKey)
            
            updateViews()
            
            replyHandler(["status":"ok"])
        }
    }

}

