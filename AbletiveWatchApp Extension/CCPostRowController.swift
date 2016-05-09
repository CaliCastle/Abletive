//
//  CCPostRowController.swift
//  Abletive
//
//  Created by Cali Castle on 1/14/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit

class CCPostRowController: NSObject {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var authorLabel: WKInterfaceLabel!
    @IBOutlet var thumbnailImage: WKInterfaceImage!
    
    var post : CCPost? {
        didSet {
            if let post = post {
                titleLabel.setText(post.title)
                authorLabel.setText(post.author)
                
                if post.thumbnailURL != nil {
                    ImageLoader.sharedLoader.imageForUrl(post.thumbnailURL!, completionHandler: { (image, url) -> () in
                        self.thumbnailImage.setImage(image)
                    })
                }
            }
        }
    }
}
