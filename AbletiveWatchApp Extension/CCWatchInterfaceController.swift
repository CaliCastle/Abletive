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

class CCWatchInterfaceController: WKInterfaceController, WCSessionDelegate {
    
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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        initSetup()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        initSetup()
    }
    
    func initSetup() {
        if let defaults = UserDefaults.standard.object(forKey: "userInformation") as? NSDictionary {
            userID = UserDefaults.standard.string(forKey: "userID")
            currentUser = CCUser(attributes: defaults)
            loggedIn = true
        } else {
            currentUser = CCUser()
        }
        updateViews()
        
        // If the WC is supported, activate it
        print(WCSession.isSupported())
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            fetchUserFromiPhone(session)
        }
    }
    
    func fetchUserFromiPhone(_ session : WCSession = WCSession.default()) {
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
    
    func getUserInformation(_ userID : String?){
        
        if userID == nil || userID == "0" {
            showErrorOverlay("用户不存在", retryable: false)
            return
        }
        
        UserDefaults.standard.set(userID!, forKey: "userID")
        
        let request = URLRequest(url: URL(string: "https://abletive.com/api/user/get_personal_page_detail/?user_id=\(userID!)")!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                // Request succeeded
                do {
                    var JSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSMutableDictionary
                    JSON = NSMutableDictionary(dictionary: JSON as [NSObject : AnyObject])
                    
                    let userMembershipInfo = NSMutableDictionary(dictionary: JSON["membership"] as! [NSObject : AnyObject])
                    
                    userMembershipInfo.removeObject(forKey: "id")
                    
                    JSON.removeObject(forKey: "membership")
                    JSON.setObject(userMembershipInfo, forKey: "membership" as NSCopying)
                    
                    UserDefaults.standard.set(JSON, forKey: "userInformation")

                    self.currentUser = CCUser(attributes: JSON as NSDictionary)

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
        if UserDefaults.standard.object(forKey: kCheckInKey) != nil {
            if loggedIn {
                checkInButton.setHidden(!UserDefaults.standard.bool(forKey: kCheckInKey))
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
                ImageLoader.sharedLoader.imageForUrl(CCFilterImageTag.filter((currentUser?.avatarURL)! as NSString)! as String, completionHandler: { (image, url) -> () in
                    if image != nil {
                        self.avatarImage.setImage(image)
                    }
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
    
    func showErrorOverlay(_ text : String = "请求出错，请重试", retryable : Bool = true) {
        let okAction = WKAlertAction(title: "知道了", style: .default) { () -> Void in
            
        }
        if (retryable) {
            let retryAction = WKAlertAction(title: "重试", style: .destructive) { () -> Void in
                self.getUserInformation(self.userID!)
            }
            presentAlert(withTitle: "出错啦", message: text, preferredStyle: .sideBySideButtonsAlert, actions: [okAction,retryAction])
        }
        presentAlert(withTitle: "出错啦", message: text, preferredStyle: .alert, actions: [okAction])
//        WKInterfaceDevice.currentDevice().playHaptic(.Retry)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func checkInDidTap() {
        // Send check in message
        if WCSession.isSupported() && loggedIn {
            checkInButton.setEnabled(false)
            checkInButton.setTitle("签到中...")
            WKInterfaceDevice.current().play(.start)
            
            let session = WCSession.default()
            
            session.sendMessage(["checkIn" : "1"], replyHandler: { (replies : Dictionary?) -> Void in
                let message = replies!["message"] as! String
                
                let action = WKAlertAction(title: "OK", style: .default, handler: { () -> Void in
                    
                })
                
                let checkedIn : Bool = (replies!["status"] as! String == "ok")
                self.presentAlert(withTitle: checkedIn ? "签到成功" : "签到失败" , message: message, preferredStyle: .alert, actions: [action])
                
                self.checkInButton.setEnabled(!checkedIn)
                self.checkInButton.setTitle("已签到")
                WKInterfaceDevice.current().play(.success)
                
                }, errorHandler: { (error) -> Void in
                    self.checkInButton.setEnabled(true)
                    self.checkInButton.setTitle("签到")
                    WKInterfaceDevice.current().play(.failure)
            })
        } else {
            showErrorOverlay("请先在iPhone上登录", retryable: false)
            WKInterfaceDevice.current().play(.failure)
        }
    }
    
    @IBAction func qrCodeButtonDidTap() {
        // Load QRCode
        // Send check in message
        if WCSession.isSupported() && loggedIn {
            let session = WCSession.default()
            WKInterfaceDevice.current().play(.success)
            session.sendMessage(["fetchQRCode":"1"], replyHandler: { (replies : Dictionary?) -> Void in
                let qrImageData = replies!["image"] as! Data
                
                self.presentController(withName: "QRCode", context: qrImageData)
                
                }, errorHandler: { (error) -> Void in
                    self.showErrorOverlay("请在iPhone上打开应用", retryable: true)
            })
        } else {
            showErrorOverlay("请先在iPhone上登录", retryable: false)
        }
    }
    
    @IBAction func refreshDidTap() {
        // Refresh everything we got here
        WKInterfaceDevice.current().play(.start)
        ImageLoader.sharedLoader.cache.removeAllObjects()
        fetchUserFromiPhone()
    }
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    private func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if message["userLoggedIn"] != nil {
            // User has logged in
            currentUser = CCUser()
        
            let userInfo = message["userInfo"] as? NSDictionary
            userID = String(userInfo!["id"] as! UInt)
            self.userDesc = userInfo!["description"] as? String
            self.currentUser?.avatarURL = (userInfo!["public_info"] as! NSDictionary)["avatar"] as? String
            
            updateViews()
            
            getUserInformation(userID!)
            loggedIn = true
        } else if message["userLoggedOut"] != nil {
            // User has logged out
            loggedIn = false
            UserDefaults.standard.removeObject(forKey: "userInformation")
            UserDefaults.standard.removeObject(forKey: "userID")
            updateViews()
        } else if message[kSettingKey] != nil {
            UserDefaults.standard.set(Int(message[kPostCountKey] as! String)!, forKey: kPostCountKey)
            UserDefaults.standard.set((message[kCheckInKey] as! Int) == 1, forKey: kCheckInKey)
            
            updateViews()
            
            replyHandler(["status":"ok" as AnyObject])
        }
    }

}

