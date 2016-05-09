//
//  SettingAppleWatchTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 1/15/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit
import WatchConnectivity

class SettingAppleWatchTableViewController: UITableViewController {

    var watchSupported : Bool = false
    
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var checkInSwitch: UISwitch!
    @IBOutlet weak var postCountStepper: UIStepper!
    
    let kCheckInKey = "Apple_Watch_Check_In_Enabled"
    let kPostCountKey = "Apple_Watch_Post_Count"
    
    var isSaving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = " Watch设置"
        
        tableView.tableFooterView = UIView()
        
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() && WCSession.defaultSession().watchAppInstalled {
                WCSession.defaultSession().activateSession()
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector(saveSettings()))
                
                watchSupported = true
                
                checkInSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(kCheckInKey) == nil ? true : NSUserDefaults.standardUserDefaults().boolForKey(kCheckInKey)
                postCountLabel.text = NSUserDefaults.standardUserDefaults().objectForKey(kPostCountKey) == nil ? "5" : NSUserDefaults.standardUserDefaults().stringForKey(kPostCountKey)
                postCountStepper.value = Double(postCountLabel.text!)!
            } else {
                navigationController?.popViewControllerAnimated(true)
                TAOverlay.showOverlayWithErrorText("您的Watch目前无法连接到，请确保已安装并打开")
            }
        } else {
            // Fallback on earlier versions
            navigationController?.popViewControllerAnimated(true)
            TAOverlay.showOverlayWithErrorText("请升级到iOS 9.0以上")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchSupported ? 3 : 0
    }

    @IBAction func checkInSwitchDidChange(sender: UISwitch) {
        if #available(iOS 9.0, *) {
            NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: kCheckInKey)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func postCountStepperDidChange(sender: UIStepper) {
        if #available(iOS 9.0, *) {
            postCountLabel.text = String(Int(sender.value))
            NSUserDefaults.standardUserDefaults().setObject(String(Int(sender.value)), forKey: kPostCountKey)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func saveSettings() {
        if isSaving {
            return
        }
        
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                let session = WCSession.defaultSession()
                
                isSaving = true
            
                session.sendMessage(["Settings_Changed":"1","CheckIn":NSUserDefaults.standardUserDefaults().boolForKey(kCheckInKey),"PostCount":NSUserDefaults.standardUserDefaults().objectForKey(kPostCountKey) == nil ? 5 : NSUserDefaults.standardUserDefaults().objectForKey(kPostCountKey)!], replyHandler: { (replies : Dictionary?) -> Void in
                    
                    self.isSaving = false
                    
                    if replies != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                            TAOverlay.showOverlayWithSuccessText("设置成功!")
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            TAOverlay.showOverlayWithErrorText("设置失败! 确保已在Watch上打开应用")
                        })
                    }
                    
                    }, errorHandler: { (error) -> Void in
                        self.isSaving = false
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            TAOverlay.showOverlayWithErrorText("设置失败! 确保已在Watch上打开应用")
                        })
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
