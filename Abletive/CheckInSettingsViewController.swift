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
        contentSizeInPopup = CGSize(width: UIScreen.mainScreen().bounds.size.width - 50, height: UIScreen.mainScreen().bounds.height * 0.56)
        view.backgroundColor = AppColor.mainWhite()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "设置提醒时间"
        
        reminderLabel.textColor = AppColor.mainBlack()
        reminderSwitch.tintColor = AppColor.secondaryBlack()
        
        datePicker.datePickerMode = .Time
        datePicker.timeZone = NSTimeZone.systemTimeZone()
        datePicker.date = NSDate()
        
        setupReminder()
        setupCustomizableTextButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(CheckInSettingsViewController.saveSettings))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reminderSwitchDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "checkin_reminder_on")
        contentSizeInPopup = CGSize(width: contentSizeInPopup.width, height: contentSizeInPopup.height + (datePicker.frame.size.height) * (sender.on ? 1 : -1))
        if sender.on {
            datePicker.hidden = false
            
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.systemTimeZone()
            formatter.dateFormat = "HH"
            
            let hour = formatter.stringFromDate(datePicker.date) as NSString
            
            formatter.dateFormat = "mm"
            
            let minute = formatter.stringFromDate(datePicker.date) as NSString
            
            NSUserDefaults.standardUserDefaults().setObject("\(hour):\(minute)", forKey: "checkin_reminder")
            
            setReminderNotification(hour.integerValue, minute: minute.integerValue)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            datePicker.hidden = true
        }
        
    }
    
    func setupReminder() {
        reminderSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("checkin_reminder_on")
        if !reminderSwitch.on {
            datePicker.hidden = true
            contentSizeInPopup = CGSize(width: contentSizeInPopup.width, height: contentSizeInPopup.height - datePicker.frame.size.height)
        }
        
        if let date = NSUserDefaults.standardUserDefaults().stringForKey("checkin_reminder") {
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.systemTimeZone()
            formatter.dateFormat = "HH:mm"
            self.datePicker.date = formatter.dateFromString(date)!
        }
    }
    
    func setupCustomizableTextButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(CheckInSettingsViewController.customizeDidClick))
    }
    
    func customizeDidClick() {
        let customizeVC = storyboard?.instantiateViewControllerWithIdentifier("CheckInCustomize") as! CheckInCustomizeTableViewController
        popupController?.pushViewController(customizeVC, animated: true)
    }
    
    func saveSettings() {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.dateFormat = "HH"
        
        let hour = formatter.stringFromDate(datePicker.date) as NSString
        
        formatter.dateFormat = "mm"
        
        let minute = formatter.stringFromDate(datePicker.date) as NSString
        
        NSUserDefaults.standardUserDefaults().setObject("\(hour):\(minute)", forKey: "checkin_reminder")
        
        if reminderSwitch.on {
            setReminderNotification(hour.integerValue, minute: minute.integerValue)
        }
        
        dismissViewControllerAnimated(true, completion: {
            () -> Void in
            
        })
    }
    
    func setReminderNotification(hour:Int, minute:Int) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let dateComp = NSDateComponents()

        let today = NSDate()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.stringFromDate(today) as NSString
        formatter.dateFormat = "MM"
        let month = formatter.stringFromDate(today) as NSString
        formatter.dateFormat = "dd"
        let day = formatter.stringFromDate(today) as NSString
        
        dateComp.year = year.integerValue
        dateComp.month = month.integerValue
        dateComp.day = day.integerValue
        
        dateComp.hour = hour
        dateComp.minute = minute
        
        dateComp.timeZone = NSTimeZone.systemTimeZone()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar?.dateFromComponents(dateComp)
        
        let notification = UILocalNotification()
        notification.category = "CHECKIN_CATEGORY"
        notification.alertBody = NSUserDefaults.standardUserDefaults().objectForKey("CheckInText") == nil ? "😳今天签到了吗？我来喊你签到啦~😉" : NSUserDefaults.standardUserDefaults().stringForKey("CheckInText") == "" ? "签到啦" : NSUserDefaults.standardUserDefaults().stringForKey("CheckInText")
        notification.fireDate = date
        notification.repeatInterval = .Day
//        notification.applicationIconBadgeNumber = 1
        notification.soundName = "Push Notification.wav"
        notification.userInfo = ["identifier":"checkin"]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
