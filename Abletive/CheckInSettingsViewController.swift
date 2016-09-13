//
//  CheckInSettingsViewController.swift
//  Abletive
//
//  Created by Cali on 11/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class CheckInSettingsViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.height * 0.56)
        view.backgroundColor = AppColor.mainWhite()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "设置提醒时间"
        
        reminderLabel.textColor = AppColor.mainBlack()
        reminderSwitch.tintColor = AppColor.secondaryBlack()
        
        datePicker.datePickerMode = .time
        datePicker.timeZone = TimeZone.current
        datePicker.date = Date()
        
        setupReminder()
        setupCustomizableTextButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CheckInSettingsViewController.saveSettings))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reminderSwitchDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "checkin_reminder_on")
        contentSizeInPopup = CGSize(width: contentSizeInPopup.width, height: contentSizeInPopup.height + (datePicker.frame.size.height) * (sender.isOn ? 1 : -1))
        if sender.isOn {
            datePicker.isHidden = false
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "HH"
            
            let hour = formatter.string(from: datePicker.date) as NSString
            
            formatter.dateFormat = "mm"
            
            let minute = formatter.string(from: datePicker.date) as NSString
            
            UserDefaults.standard.set("\(hour):\(minute)", forKey: "checkin_reminder")
            
            setReminderNotification(hour.integerValue, minute: minute.integerValue)
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
            datePicker.isHidden = true
        }
        
    }
    
    func setupReminder() {
        reminderSwitch.isOn = UserDefaults.standard.bool(forKey: "checkin_reminder_on")
        if !reminderSwitch.isOn {
            datePicker.isHidden = true
            contentSizeInPopup = CGSize(width: contentSizeInPopup.width, height: contentSizeInPopup.height - datePicker.frame.size.height)
        }
        
        if let date = UserDefaults.standard.string(forKey: "checkin_reminder") {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "HH:mm"
            self.datePicker.date = formatter.date(from: date)!
        }
    }
    
    func setupCustomizableTextButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(CheckInSettingsViewController.customizeDidClick))
    }
    
    func customizeDidClick() {
        let customizeVC = storyboard?.instantiateViewController(withIdentifier: "CheckInCustomize") as! CheckInCustomizeTableViewController
        popupController?.push(customizeVC, animated: true)
    }
    
    func saveSettings() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH"
        
        let hour = formatter.string(from: datePicker.date) as NSString
        
        formatter.dateFormat = "mm"
        
        let minute = formatter.string(from: datePicker.date) as NSString
        
        UserDefaults.standard.set("\(hour):\(minute)", forKey: "checkin_reminder")
        
        if reminderSwitch.isOn {
            setReminderNotification(hour.integerValue, minute: minute.integerValue)
        }
        
        dismiss(animated: true, completion: {
            () -> Void in
            
        })
    }
    
    func setReminderNotification(_ hour:Int, minute:Int) {
        UIApplication.shared.cancelAllLocalNotifications()
        
        var dateComp = DateComponents()

        let today = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: today) as NSString
        formatter.dateFormat = "MM"
        let month = formatter.string(from: today) as NSString
        formatter.dateFormat = "dd"
        let day = formatter.string(from: today) as NSString
        
        dateComp.year = year.integerValue
        dateComp.month = month.integerValue
        dateComp.day = day.integerValue
        
        dateComp.hour = hour
        dateComp.minute = minute
        
        (dateComp as NSDateComponents).timeZone = TimeZone.current
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComp)
        
        let notification = UILocalNotification()
        notification.category = "CHECKIN_CATEGORY"
        notification.alertBody = UserDefaults.standard.object(forKey: "CheckInText") == nil ? "😳今天签到了吗？我来喊你签到啦~😉" : UserDefaults.standard.string(forKey: "CheckInText") == "" ? "签到啦" : UserDefaults.standard.string(forKey: "CheckInText")
        notification.fireDate = date
        notification.repeatInterval = .day
//        notification.applicationIconBadgeNumber = 1
        notification.soundName = "Push Notification.wav"
        notification.userInfo = ["identifier":"checkin"]
        
        UIApplication.shared.scheduleLocalNotification(notification)
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
