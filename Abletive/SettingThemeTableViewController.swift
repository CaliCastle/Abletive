//
//  SettingThemeTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/26/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class SettingThemeTableViewController: UITableViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.size.height - 250)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        title = "选择主题"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set((indexPath as NSIndexPath).row, forKey: "theme")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "themeChanged"), object: nil)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingThemeCell", for: indexPath)

        // Configure the cell...
        if UserDefaults.standard.integer(forKey: "theme") == (indexPath as NSIndexPath).row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "默认主题(黄黑)"
                break;
            case 1:
                cell.textLabel?.text = "明亮主题"
                break;
            default:
                break;
        }

        return cell
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
