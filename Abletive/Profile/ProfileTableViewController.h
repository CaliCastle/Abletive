//
//  ProfileTableViewController.h
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileDelegate <NSObject>

- (void)updateHeaderData;
- (void)userDidClickLogout;

@end

@interface ProfileTableViewController : UITableViewController

@property (nonatomic,weak) id <ProfileDelegate> delegate;

@end
