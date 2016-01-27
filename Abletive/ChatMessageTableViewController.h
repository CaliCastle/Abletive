//
//  ChatMessageTableViewController.h
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ChatMessageTableViewController : UIViewController

@property (nonatomic,strong) User *currentUser;

@property (nonatomic,assign) NSUInteger userID;

@end
