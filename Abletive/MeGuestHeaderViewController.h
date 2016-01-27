//
//  MeGuestHeaderViewController.h
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeGuestHeaderViewDelegate <NSObject>

- (void)openLoginPanel;

@end

@interface MeGuestHeaderViewController : UIViewController

@property (nonatomic,weak) id<MeGuestHeaderViewDelegate> delegate;

@end
