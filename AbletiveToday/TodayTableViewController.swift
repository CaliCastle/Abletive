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

        tableView.backgroundColor = UIColor.clear()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.lightGray()
        
        updateSize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postCount = UserDefaults(suiteName: "group.abletive")?.value(forKey: "todayCount") == nil ? 3 : UserDefaults(suiteName: "group.abletive")?.value(forKey: "todayCount") as! Int
        
        updateSize()
        tableView.reloadData()
    }
    
    func updateSize() {
        var preferredSize = self.preferredContentSize
        preferredSize.height = preferredViewHeight
        self.preferredContentSize = preferredSize
    }
    
    // MARK: - Widget Delegate
    
    func widgetPerformUpdate(completionHandler: (NCUpdateResult) -> Void) {
        self.tableView.reloadData()
        completionHandler(.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postCount
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCell", for: indexPath) as! TodayTableViewCell

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.frame = cell.thumbnailView.frame
        indicator.center = cell.thumbnailView.center
        cell.thumbnailView.addSubview(indicator)
        indicator.startAnimating()
        
        Post.globalTimelinePosts(withPage: (indexPath as NSIndexPath).row + 1) { (post : Post!, error : NSError!) -> Void in
            if error == nil {
                cell.currentPost = post
            
                if post.imageMediumPath != nil && post.imageMediumPath != "" {
                    self.getDataFromUrl(URL(string: post.imageMediumPath)!, completion: { (data, response, error) -> Void in
                        if error == nil {
                            DispatchQueue.main.async(execute: { () -> Void in
                                indicator.removeFromSuperview()
                                let image = UIImage(data: data!, scale: 1)
                                cell.thumbnailView.image = image
                                cell.thumbnailView.contentMode = .scaleAspectFit
                            })
                        }
                    })
                } else {
                    indicator.removeFromSuperview()
                    cell.thumbnailView.image = UIImage(named: "placeholder")
                    cell.thumbnailView.contentMode = .scaleAspectFit
                }
                cell.titleLabel.text = post.title
                cell.authorLabel.text = post.author.name
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear().cgColor
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TodayTableViewCell
        if cell.currentPost != nil {
            extensionContext?.open(URL(string: "abletive://today_click/\(cell.currentPost.postID)")!, completionHandler: nil)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromUrl(_ url:URL, completion: ((data: Data?, response: URLResponse?, error: NSError? ) -> Void)) {
        URLSession.shared().dataTask(with: url) { (data, response, error) in
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
