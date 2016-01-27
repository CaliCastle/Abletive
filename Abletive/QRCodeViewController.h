//
//  QRCodeViewController.h
//  Abletive
//
//  Created by Cali on 11/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,QRCodeScanType) {
    QRCodeScanTypeURL,
    QRCodeScanTypePersonalCard,
    QRCodeScanTypeEvent,
    QRCodeScanTypeText
};

@interface QRCodeViewController : UIViewController

@end
