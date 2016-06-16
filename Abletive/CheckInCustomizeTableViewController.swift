//
//  CheckInCustomizeTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 12/31/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class CheckInCustomizeTableViewController: UITableViewController {

    @IBOutlet weak var customizeTextField: UITextField!
    
    override func awakeFromNib() {
        contentSizeInPopup = CGSize(width: UIScreen.main().bounds.size.width - 45, height: UIScreen.main().bounds.size.height * 0.35)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "自定义提醒内容"
        
        tableView.tableFooterView = UIView()
        customizeTextField.backgroundColor = AppColor.transparent()
        customizeTextField.text = UserDefaults.standard().string(forKey: "CheckInText")
        
        customizeTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    @IBAction func customizeTextFieldDidEndOnExit(_ sender: UITextField) {
        if sender.text?.characters.count >= 35 {
            MozTopAlertView.show(with: MozAlertTypeError, text: "长度不能超过20", parentView: popupController?.navigationBar)
        } else {
            sender.resignFirstResponder()
            
            UserDefaults.standard().set(sender.text, forKey: "CheckInText")
            
            popupController?.popViewController(animated: true)
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
