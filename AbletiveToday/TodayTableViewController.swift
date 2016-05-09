//
//  TodayTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayTableViewController: UITableViewController,NCWidgetProviding {

    var postCount = 3
    
    var allPosts : NSMutableArray {
        return NSMutableArray()
    }
    
    var preferredViewHeight : CGFloat {
        return CGFloat(75 * postCount) + 5.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.lightGrayColor()
        
        updateSize()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        postCount = NSUserDefaults(suiteName: "group.abletive")?.valueForKey("todayCount") == nil ? 3 : NSUserDefaults(suiteName: "group.abletive")?.valueForKey("todayCount") as! Int
        
        updateSize()
        tableView.reloadData()
    }
    
    func updateSize() {
        var preferredSize = self.preferredContentSize
        preferredSize.height = preferredViewHeight
        self.preferredContentSize = preferredSize
    }
    
    // MARK: - Widget Delegate
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: (NCUpdateResult) -> Void) {
        self.tableView.reloadData()
        completionHandler(.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postCount
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TodayCell", forIndexPath: indexPath) as! TodayTableViewCell

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        indicator.frame = cell.thumbnailView.frame
        indicator.center = cell.thumbnailView.center
        cell.thumbnailView.addSubview(indicator)
        indicator.startAnimating()
        
        Post.globalTimelinePostsWithPage(indexPath.row + 1) { (post : Post!, error : NSError!) -> Void in
            if error == nil {
                cell.currentPost = post
            
                if post.imageMediumPath != nil && post.imageMediumPath != "" {
                    self.getDataFromUrl(NSURL(string: post.imageMediumPath)!, completion: { (data, response, error) -> Void in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                indicator.removeFromSuperview()
                                let image = UIImage(data: data!, scale: 1)
                                cell.thumbnailView.image = image
                                cell.thumbnailView.contentMode = .ScaleAspectFit
                            })
                        }
                    })
                } else {
                    indicator.removeFromSuperview()
                    cell.thumbnailView.image = UIImage(named: "placeholder")
                    cell.thumbnailView.contentMode = .ScaleAspectFit
                }
                cell.titleLabel.text = post.title
                cell.authorLabel.text = post.author.name
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TodayTableViewCell
        if cell.currentPost != nil {
            extensionContext?.openURL(NSURL(string: "abletive://today_click/\(cell.currentPost.postID)")!, completionHandler: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
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
