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
        
        checkInSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(kCheckInItemKey) == nil ? false : NSUserDefaults.standardUserDefaults().boolForKey(kCheckInItemKey)
        
        if #available(iOS 9.0, *) {
            

        } else {
            // Fallback on earlier versions
            navigationController?.popViewControllerAnimated(true)
            TAOverlay.showOverlayWithErrorText("您的iOS不支持3D Touch功能")
        }
        
    }

    @IBAction func checkInSwitchDidChange(sender: UISwitch) {
        changeShortcutItem(sender.on)
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: kCheckInItemKey)
    }
    
    func changeShortcutItem(checkInEnabled : Bool) {
        if #available(iOS 9.0, *) {
            var shortcutItems = UIApplication.sharedApplication().shortcutItems
            
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
            
            shortcutItems?.removeAtIndex(index)
            shortcutItems?.insert(item, atIndex: index)
            
            UIApplication.sharedApplication().shortcutItems = shortcutItems
            
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
