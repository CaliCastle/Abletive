//
//  RegisterTableViewController.h
//  Abletive
//
//  Created by Cali on 6/20/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbletiveAPIClient.h"

@protocol RegisterTableViewDelegate <NSObject>

- (void)youShouldDismiss;

@end

@interface RegisterTableViewController : UITableViewController

@property (weak,nonatomic) id<RegisterTableViewDelegate> delegate;

@end
