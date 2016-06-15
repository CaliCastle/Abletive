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
        
        blurSwitch.isOn = UserDefaults.standard().bool(forKey: "Background_Blur")
        authSwitch.isOn = UserDefaults.standard().bool(forKey: "Authentication_Profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func blurSwitchDidChange(_ sender: UISwitch) {
        UserDefaults.standard().set(sender.isOn, forKey: "Background_Blur")
    }
    
    @IBAction func authSwitchDidChange(_ sender: UISwitch) {
        authenticateUser(sender.isOn)
    }

    func authenticateUser(_ on : Bool) -> Void {
        let context = LAContext()
        var error : NSError?
        
        if #available(iOS 9.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "用来验证身份，保护资料信息", reply: { (success, error) in
                    if success {
                        DispatchQueue.main.async(execute: {
                            UserDefaults.standard().set(on, forKey: "Authentication_Profile")
                        })
                    } else {
                        DispatchQueue.main.async(execute: { 
                            self.authSwitch.setOn(!on, animated: true)
                        })
                    }
                })
            }
        } else {
            // Fallback on earlier versions
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "用来验证身份，保护资料信息", reply: { (success, error) in
                    if success {
                        DispatchQueue.main.async(execute: {
                            UserDefaults.standard().set(on, forKey: "Authentication_Profile")
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
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
