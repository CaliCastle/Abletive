//
//  SinglePostTableViewController.h
//  Abletive
//
//  Created by Cali on 7/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetail.h"
#import "Comment.h"

@interface SinglePostTableViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic,strong) PostDetail *currentPost;

@property (nonatomic,assign) NSUInteger postID;

@property (nonatomic,strong) NSString *postSlug;

@property (nonatomic,assign) BOOL isFromPeek;

@property (nonatomic,assign) BOOL isPage;

@end
