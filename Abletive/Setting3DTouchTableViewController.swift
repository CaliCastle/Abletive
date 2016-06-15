//
//  Setting3DTouchTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 1/15/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class Setting3DTouchTableViewController: UITableViewController {

    @IBOutlet weak var checkInSwitch: UISwitch!
    
    let kCheckInItemKey = "3DTouchCheckInEnabled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        checkInSwitch.isOn = UserDefaults.standard().object(forKey: kCheckInItemKey) == nil ? false : UserDefaults.standard().bool(forKey: kCheckInItemKey)
        
        if #available(iOS 9.0, *) {
            

        } else {
            // Fallback on earlier versions
            navigationController?.popViewController(animated: true)
            TAOverlay.showWithErrorText("您的iOS不支持3D Touch功能")
        }
        
    }

    @IBAction func checkInSwitchDidChange(_ sender: UISwitch) {
        changeShortcutItem(sender.isOn)
        UserDefaults.standard().set(sender.isOn, forKey: kCheckInItemKey)
    }
    
    func changeShortcutItem(_ checkInEnabled : Bool) {
        if #available(iOS 9.0, *) {
            var shortcutItems = UIApplication.shared().shortcutItems
            
            var index = 0
            for shortcutItem : UIApplicationShortcutItem in shortcutItems! {
                if shortcutItem.type == (checkInEnabled ? "Settings" : "CheckIn") {
                    break
                }
                index += 1
            }
            var item = shortcutItems![index]
            if checkInEnabled {
                item = UIApplicationShortcutItem(type: "CheckIn", localizedTitle: "签到", localizedSubtitle: "一键快速签到", icon: UIApplicationShortcutIcon(templateImageName: "checkin"), userInfo: nil)
            } else {
                item = UIApplicationShortcutItem(type: "Settings", localizedTitle: "设置", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "setting"), userInfo: nil)
            }
            
            shortcutItems?.remove(at: index)
            shortcutItems?.insert(item, at: index)
            
            UIApplication.shared().shortcutItems = shortcutItems
            
        } else {
            // Fallback on earlier versions
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
