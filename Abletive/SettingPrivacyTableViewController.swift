//
//  SettingPrivacyTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/26/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingPrivacyTableViewController: UITableViewController {

    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var authSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("Background_Blur")
        authSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("Authentication_Profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func blurSwitchDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "Background_Blur")
    }
    
    @IBAction func authSwitchDidChange(sender: UISwitch) {
        authenticateUser(sender.on)
    }

    func authenticateUser(on : Bool) -> Void {
        let context = LAContext()
        var error : NSError?
        
        if #available(iOS 9.0, *) {
            if context.canEvaluatePolicy(.DeviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.DeviceOwnerAuthentication, localizedReason: "用来验证身份，保护资料信息", reply: { (success, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSUserDefaults.standardUserDefaults().setBool(on, forKey: "Authentication_Profile")
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.authSwitch.setOn(!on, animated: true)
                        })
                    }
                })
            }
        } else {
            // Fallback on earlier versions
            if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "用来验证身份，保护资料信息", reply: { (success, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSUserDefaults.standardUserDefaults().setBool(on, forKey: "Authentication_Profile")
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.authSwitch.setOn(!on, animated: true)
                        })
                    }
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
