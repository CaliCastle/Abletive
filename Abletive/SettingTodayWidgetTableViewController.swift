//
//  SettingTodayWidgetTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 1/15/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class SettingTodayWidgetTableViewController: UITableViewController {

    @IBOutlet weak var postCountStepper: UIStepper!
    @IBOutlet weak var postCountLabel: UILabel!
    
    let kGroupName = "group.abletive"
    let kTodayCountKey = "todayCount"
    
    let defaults = UserDefaults(suiteName: "group.abletive")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "通知中心设置"
        
        tableView.tableFooterView = UIView()
        
        postCountStepper.value = defaults!.object(forKey: kTodayCountKey) == nil ? 3.0 : Double((defaults?.integer(forKey: kTodayCountKey))!)
        postCountLabel.text = "\(Int(postCountStepper.value))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func countStepperDidChange(_ sender: UIStepper) {
        postCountLabel.text = "\(Int(sender.value))"
        defaults?.set(Int(sender.value), forKey: kTodayCountKey)
        defaults?.synchronize()
    }

    // MARK: - Table view data source
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
