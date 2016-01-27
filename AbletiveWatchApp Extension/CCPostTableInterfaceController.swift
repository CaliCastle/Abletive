//
//  CCPostTableInterfaceController.swift
//  Abletive
//
//  Created by Cali Castle on 1/14/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit
import Foundation


class CCPostTableInterfaceController: WKInterfaceController {

    @IBOutlet var postTable: WKInterfaceTable!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var loadMoreButton: WKInterfaceButton!
    
    static var page : UInt = 1
    static var count : UInt = 5
    var posts : Array<CCPost> = CCPost.allPosts()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        CCPostTableInterfaceController.count = NSUserDefaults.standardUserDefaults().objectForKey("PostCount") == nil ? 5 : UInt(NSUserDefaults.standardUserDefaults().integerForKey("PostCount"))
        
        fetchPosts()
    }
    
    func fetchPosts() {
        loadingLabel.setHidden(false)
        loadMoreButton.setHidden(true)
        CCPost.fetchPosts(CCPostTableInterfaceController.page++, count: CCPostTableInterfaceController.count) { (posts) -> Void in
            if posts.count > 0 {
                self.loadingLabel.setHidden(true)
                self.loadMoreButton.setHidden(false)
                
                self.posts = posts
                self.updateRows()
            } else {
                self.loadMoreButton.setHidden(true)
            }
        }
    }
    
    func updateRows() {
        postTable.setNumberOfRows(posts.count, withRowType: "PostRow")
        
        for index in 0..<postTable.numberOfRows {
            if let controller = postTable.rowControllerAtIndex(index) as? CCPostRowController {
                controller.post = CCPost.allPosts()[index]
            }
            
        }
    }

    @IBAction func loadMoreDidTap() {
        fetchPosts()
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
