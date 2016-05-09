//
//  ChatShareTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 3/19/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ChatShareTableViewController: UITableViewController {

    var chatTVC : ChatTableViewController? {
        get {
            let rootVC = UIApplication.sharedApplication().windows.first?.rootViewController as! UITabBarController
            
            let naviController = rootVC.viewControllers![1] as! UINavigationController
            
            return naviController.viewControllers[0] as? ChatTableViewController
        }
    }
    
    var delegate : SinglePostTableViewController?
    
    var linkAddress = ""
    var sharePrefix = ""
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "分享好友"
        
        contentSizeInPopup = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 50, UIScreen.mainScreen().bounds.size.height - 150)
        landscapeContentSizeInPopup = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 150, 100)
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatTVC!.allNotifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShareReuse", forIndexPath: indexPath) as! ChatShareTableViewCell

        // Configure the cell...
        cell.notification = chatTVC!.allNotifications[indexPath.row] as? Notification

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notif = chatTVC!.allNotifications[indexPath.row] as? Notification
        
        TAOverlay.showOverlayWithLogoAndLabel("正在分享中...")
      
        ChatMessage.sendChatMessageWithContent("\(sharePrefix) \(linkAddress)", andToWhom: (notif?.user.userID)!) { (success, newMessage) -> Void in
            TAOverlay.hideOverlay()
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate!.shared()
            })
        }
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
