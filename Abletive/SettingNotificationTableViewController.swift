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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            
            DispatchQueue.main.async(execute: { () -> Void in
                let popup = STPopupController(rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "CheckInSettings"))
                popup?.cornerRadius = 12
                popup?.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                popup?.present(in: self)
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
