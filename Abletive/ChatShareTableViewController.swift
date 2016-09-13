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
            let rootVC = UIApplication.shared.windows.first?.rootViewController as! UITabBarController
            
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
        
        contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.size.height - 150)
        landscapeContentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 150, height: 100)
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatTVC!.allNotifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareReuse", for: indexPath) as! ChatShareTableViewCell

        // Configure the cell...
        cell.notification = chatTVC!.allNotifications[(indexPath as NSIndexPath).row] as? CCNotification

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notif = chatTVC!.allNotifications[(indexPath as NSIndexPath).row] as? CCNotification
        
        TAOverlay.show(withLogoAndLabel: "正在分享中...")
      
        ChatMessage.send(withContent: "\(sharePrefix) \(linkAddress)", andToWhom: (notif?.user.userID)!) { (success, newMessage) -> Void in
            TAOverlay.hide()
            self.dismiss(animated: true, completion: { () -> Void in
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
