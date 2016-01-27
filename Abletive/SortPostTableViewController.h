//
//  SortPostTableViewController.h
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface SortPostTableViewController : UITableViewController

@property (nonatomic,assign) NSUInteger identification;
@property (nonatomic,assign) PostSortType sortType;
@property (nonatomic,strong) NSString *date;

@end
