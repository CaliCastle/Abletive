//
//  CheckInViewController.h
//  Abletive
//
//  Created by Cali on 10/12/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol CheckInDelegate <NSObject>

- (void)userAvatarDidTap:(User *)user;

@end

@interface CheckInViewController : UIViewController

@property (nonatomic,weak) id<CheckInDelegate> delegate;

@end
