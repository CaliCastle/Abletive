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
        
        self.tableView.indicatorStyle = .white
        
        fetchInboxData()
    }
    
    func fetchInboxData() -> Void {
        if fetching {
            return
        }
        TAOverlay.showWithLoading()
        fetching = true
        Inbox.getInboxMessages(page, count: count) { (inboxes, error) in
            TAOverlay.hide()
            self.fetching = false
            if error == nil {
                self.page += 1
                if inboxes?.count == 0 || inboxes?.count < self.count {
                    self.noMore = true
                }
                for i in 0..<(inboxes?.count)! {
                    self.allInboxes.append((inboxes?[i])!)
                }
                self.tableView.reloadData()
            } else {
                TAOverlay.showWithError()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 50 {
            if !noMore {
                fetchInboxData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInboxes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxReuse", for: indexPath) as! InboxTableViewCell

        // Configure the cell...
        cell.inbox = allInboxes[(indexPath as NSIndexPath).row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allInboxes.count == 0 {
            return
        }
        let inbox = allInboxes[(indexPath as NSIndexPath).row]
        
        let postTVC = storyboard?.instantiateViewController(withIdentifier: "SinglePostTVC") as! SinglePostTableViewController
        
        let range = (inbox.url as NSString).range(of: "#")
        var url = (inbox.url as NSString).substring(to: range.location)
        url = url.replacingOccurrences(of: "comment-page-", with: "")
        
        url = (url as NSString).reverse()
        
        while (url as NSString).substring(to: 1) != "/" {
            url = ((url as NSString).reverse() as NSString).substring(to: url.characters.count-1)
            url = (url as NSString).reverse()
        }
        url = ((url as NSString).reverse() as NSString).substring(to: url.characters.count-1)
        
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
