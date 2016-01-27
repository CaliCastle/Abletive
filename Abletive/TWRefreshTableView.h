//
//  TWRefreshTableView.h
//  TWRefreshDemo
//
//  Created by Chris on 15/6/15.
//  Copyright (c) 2015 EasyBaking. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TWRefresh.h"
#import "TWRefresh.h"

@protocol TWTableViewRefreshingDelegate;

@interface TWRefreshTableView : UITableView

//Refresh Delegate
@property (nonatomic, weak) id<TWTableViewRefreshingDelegate> refreshDelegate;

// Constructors
- (id) initWithFrame:(CGRect)frame refreshType:(TWRefreshType)type;
- (id) initWithFrame:(CGRect)frame refreshType:(TWRefreshType)type andAutoLoad:(BOOL) autoLoad;
- (id) initWithFrame:(CGRect)frame andAutoLoad:(BOOL) autoLoad;
- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle) style refreshType:(TWRefreshType)type andAutoLoad:(BOOL) autoLoad;

@end

@protocol TWTableViewRefreshingDelegate <NSObject>

@optional
- (void) beginRefreshHeader:(TWRefreshTableView*) tableView;
- (void) beginRefreshFooter:(TWRefreshTableView*) tableView;

@end
