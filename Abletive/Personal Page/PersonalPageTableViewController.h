//
//  PersonalPageTableViewController.h
//  Abletive
//
//  Created by Cali on 10/9/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "PersonalPageHeaderViewController.h"

@protocol PersonalPageDelegate <NSObject>

- (void)followActionSucceeded:(PersonalPageFollowStatus)status;

@end

@interface PersonalPageTableViewController : UITableViewController

@property (nonatomic,strong) User *currentUser;

@property (nonatomic,assign) PersonalPageViewType currentViewType;

@property (nonatomic,strong) PersonalPageHeaderViewController *headerViewController;

@property (nonatomic,weak) id <PersonalPageDelegate> delegate;

@end
