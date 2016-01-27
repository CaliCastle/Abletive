//
//  PostTableViewController.h
//  Abletive
//
//  Created by Cali on 6/13/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableViewController : UITableViewController

/**
 *  All the loaded post in NSDictionary
 */
@property (nonatomic,strong) NSMutableArray *allRawPosts;

@end
