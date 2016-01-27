//
//  CCQRCodeInterfaceController.swift
//  Abletive
//
//  Created by Cali Castle on 1/14/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class CCQRCodeInterfaceController: WKInterfaceController,WCSessionDelegate {

    @IBOutlet var qrCodeImage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        qrCodeImage.setImageData(context as? NSData)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
