//
//  InboxTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 3/17/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController {

    var page = 1
    var count = 20
    
    var allInboxes = [Inbox]()
    
    var noMore = false
    var fetching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "评论回复"
        
        self.tableView.indicatorStyle = .White
        
        fetchInboxData()
    }
    
    func fetchInboxData() -> Void {
        if fetching {
            return
        }
        TAOverlay.showOverlayWithLoading()
        fetching = true
        Inbox.getInboxMessages(page, count: count) { (inboxes, error) in
            TAOverlay.hideOverlay()
            self.fetching = false
            if error == nil {
                self.page += 1
                if inboxes.count == 0 || inboxes.count < self.count {
                    self.noMore = true
                }
                for i in 0..<inboxes.count {
                    self.allInboxes.append(inboxes[i])
                }
                self.tableView.reloadData()
            } else {
                TAOverlay.showOverlayWithError()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 50 {
            if !noMore {
                fetchInboxData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInboxes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxReuse", forIndexPath: indexPath) as! InboxTableViewCell

        // Configure the cell...
        cell.inbox = allInboxes[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if allInboxes.count == 0 {
            return
        }
        let inbox = allInboxes[indexPath.row]
        
        let postTVC = storyboard?.instantiateViewControllerWithIdentifier("SinglePostTVC") as! SinglePostTableViewController
        
        let range = (inbox.url as NSString).rangeOfString("#")
        var url = (inbox.url as NSString).substringToIndex(range.location)
        url = url.stringByReplacingOccurrencesOfString("comment-page-", withString: "")
        
        url = (url as NSString).reverse()
        
        while (url as NSString).substringToIndex(1) != "/" {
            url = ((url as NSString).reverse() as NSString).substringToIndex(url.characters.count-1)
            url = (url as NSString).reverse()
        }
        url = ((url as NSString).reverse() as NSString).substringToIndex(url.characters.count-1)
        
        postTVC.postSlug = url
        
        print(postTVC.postSlug)
        
        navigationController?.pushViewController(postTVC, animated: true)
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
