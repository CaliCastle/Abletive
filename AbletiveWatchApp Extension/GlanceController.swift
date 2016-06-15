//
//  GlanceController.swift
//  AbletiveWatchApp Extension
//
//  Created by Cali Castle on 1/13/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var authorLabel: WKInterfaceLabel!
    @IBOutlet var thumbnailImage: WKInterfaceImage!
    
    override func awake(withContext context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        DispatchQueue.main.async { () -> Void in
            self.updatePost()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updatePost()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updatePost() {
        CCPost.latest { (post) -> Void in
            self.titleLabel.setText(post.title)
            self.authorLabel.setText(post.author)
            
            if post.thumbnailURL != nil {
                ImageLoader.sharedLoader.imageForUrl(post.thumbnailURL!, completionHandler: { (image, url) -> () in
                    self.thumbnailImage.setImage(image)
                })
            }
        }
    }

}
