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
            if WCSession.isSupported() && WCSession.default().isWatchAppInstalled {
                WCSession.default().activate()
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SettingAppleWatchTableViewController.saveSettings))
                
                watchSupported = true
                
                checkInSwitch.isOn = UserDefaults.standard.object(forKey: kCheckInKey) == nil ? true : UserDefaults.standard.bool(forKey: kCheckInKey)
                postCountLabel.text = UserDefaults.standard.object(forKey: kPostCountKey) == nil ? "5" : UserDefaults.standard.string(forKey: kPostCountKey)
                postCountStepper.value = Double(postCountLabel.text!)!
            } else {
                navigationController?.popViewController(animated: true)
                TAOverlay.showWithErrorText("您的Watch目前无法连接到，请确保已安装并打开")
            }
        } else {
            // Fallback on earlier versions
            navigationController?.popViewController(animated: true)
            TAOverlay.showWithErrorText("请升级到iOS 9.0以上")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchSupported ? 3 : 0
    }

    @IBAction func checkInSwitchDidChange(_ sender: UISwitch) {
        if #available(iOS 9.0, *) {
            UserDefaults.standard.set(sender.isOn, forKey: kCheckInKey)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func postCountStepperDidChange(_ sender: UIStepper) {
        if #available(iOS 9.0, *) {
            postCountLabel.text = String(Int(sender.value))
            UserDefaults.standard.set(String(Int(sender.value)), forKey: kPostCountKey)
            
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
                let session = WCSession.default()
                
                isSaving = true
            
                session.sendMessage(["Settings_Changed":"1","CheckIn":UserDefaults.standard.bool(forKey: kCheckInKey),"PostCount":UserDefaults.standard.object(forKey: kPostCountKey) == nil ? 5 : UserDefaults.standard.object(forKey: kPostCountKey)!], replyHandler: { (replies : Dictionary?) -> Void in
                    
                    self.isSaving = false
                    
                    if replies != nil {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.navigationController?.popViewController(animated: true)
                            TAOverlay.show(withSuccessText: "设置成功!")
                        })
                    } else {
                        DispatchQueue.main.async(execute: { () -> Void in
                            TAOverlay.showWithErrorText("设置失败! 确保已在Watch上打开应用")
                        })
                    }
                    
                    }, errorHandler: { (error) -> Void in
                        self.isSaving = false
                        DispatchQueue.main.async(execute: { () -> Void in
                            TAOverlay.showWithErrorText("设置失败! 确保已在Watch上打开应用")
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
