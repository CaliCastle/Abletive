//
//  SettingNotificationTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class SettingNotificationTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupControls()
    }

    func setupControls() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let popup = STPopupController(rootViewController: self.storyboard?.instantiateViewControllerWithIdentifier("CheckInSettings"))
                popup.cornerRadius = 12
                popup.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
                popup.presentInViewController(self)
            })
            
            break
        default:
            break
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
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
