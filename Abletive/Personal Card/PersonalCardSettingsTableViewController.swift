//
//  PersonalCardSettingsTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

public protocol PersonalCardSettingsDelegate : NSObjectProtocol {
    func settingsChanged(userInfo:NSDictionary)
}

class PersonalCardSettingsTableViewController: UITableViewController,PersonalCardWallpaperDelegate {

    weak var delegate : PersonalCardSettingsDelegate?
    
    @IBOutlet weak var backgroundBlurSwitch: UISwitch!
    @IBOutlet weak var qrCodeStyleSwitch: UISwitch!
    var backgroundIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: UIScreen.mainScreen().bounds.size.width - 50, height: UIScreen.mainScreen().bounds.height - 250)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "更改名片样式"
        
        view.backgroundColor = AppColor.secondaryBlack()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "saveSettings")
        backgroundIndex = NSUserDefaults.standardUserDefaults().integerForKey("card-backgroundIndex")
        backgroundBlurSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("card-blur")
        qrCodeStyleSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("card-qrCodeStyle")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backgroundBlurDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "card-blur")
    }
    
    @IBAction func qrCodeStyleDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "card-qrCodeStyle")
    }
    
    func saveSettings() {
        let userInfo = NSDictionary(objects: [self.backgroundBlurSwitch.on,self.qrCodeStyleSwitch.on,self.backgroundIndex], forKeys: ["blur","qrcode","bgindex"])
        dismissViewControllerAnimated(true, completion: nil)
        
        delegate?.settingsChanged(userInfo)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let wallpaperChooser = storyboard?.instantiateViewControllerWithIdentifier("PersonalCardWallpaper") as! PersonalCardWallpaperCollectionViewController
            wallpaperChooser.delegate = self
            popupController?.pushViewController(wallpaperChooser, animated: true)
        }
    }
    
    // MARK: - Personal Card Wallpaper Delegate
    
    func didSelectWallpaperAtIndex(index: Int) {
        backgroundIndex = index
        NSUserDefaults.standardUserDefaults().setInteger(backgroundIndex, forKey: "card-backgroundIndex")
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
