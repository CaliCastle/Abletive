//
//  PersonalCardSettingsTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

public protocol PersonalCardSettingsDelegate : NSObjectProtocol {
    func settingsChanged(_ userInfo:NSDictionary)
}

class PersonalCardSettingsTableViewController: UITableViewController,PersonalCardWallpaperDelegate {

    weak var delegate : PersonalCardSettingsDelegate?
    
    @IBOutlet weak var backgroundBlurSwitch: UISwitch!
    @IBOutlet weak var qrCodeStyleSwitch: UISwitch!
    var backgroundIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.height - 250)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "更改名片样式"
        
        view.backgroundColor = AppColor.secondaryBlack()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PersonalCardSettingsTableViewController.saveSettings))
        backgroundIndex = UserDefaults.standard.integer(forKey: "card-backgroundIndex")
        backgroundBlurSwitch.isOn = UserDefaults.standard.bool(forKey: "card-blur")
        qrCodeStyleSwitch.isOn = UserDefaults.standard.bool(forKey: "card-qrCodeStyle")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backgroundBlurDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "card-blur")
    }
    
    @IBAction func qrCodeStyleDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "card-qrCodeStyle")
    }
    
    func saveSettings() {
        let userInfo = NSDictionary(objects: [self.backgroundBlurSwitch.isOn,self.qrCodeStyleSwitch.isOn,self.backgroundIndex], forKeys: ["blur" as NSCopying,"qrcode" as NSCopying,"bgindex" as NSCopying])
        dismiss(animated: true, completion: nil)
        
        delegate?.settingsChanged(userInfo)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            let wallpaperChooser = storyboard?.instantiateViewController(withIdentifier: "PersonalCardWallpaper") as! PersonalCardWallpaperCollectionViewController
            wallpaperChooser.delegate = self
            popupController?.push(wallpaperChooser, animated: true)
        }
    }
    
    // MARK: - Personal Card Wallpaper Delegate
    
    func didSelectWallpaperAtIndex(_ index: Int) {
        backgroundIndex = index
        UserDefaults.standard.set(backgroundIndex, forKey: "card-backgroundIndex")
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
