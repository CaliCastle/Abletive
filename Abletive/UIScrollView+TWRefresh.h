//
//  UIScrollView+TWRefres.h
//  EasyBaking
//
//  Created by Chris on 12/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWRefreshView.h"
#import "TWRefreshIndicator.h"

@interface UIScrollView (TWRefresh)

// Set refresh Header indicator
- (void) setRefreshHeaderIndicator:(id<TWRefreshIndicator>) indicator;

// Set refresh Header with indicator class
- (void) setRefreshHeaderWithIndicatorClass:(Class) clazz;

// Set refresh Footer indicator
- (void) setRefreshFooterIndicator:(id<TWRefreshIndicator>) indicator;

// Set refresh Footer with indicator class
- (void) setRefreshFooterWithIndicatorClass:(Class) clazz;

// Stop Header Refreshing
- (void) stopHeaderRefreshing;

// Stop Footer Refreshing
- (void) stopFooterRefreshing;

// Header Refresing
- (void) refreshHeader;

// Footer Refresing
- (void) refreshFooter;

// Set refresh enabled, sometimes you need to switch refreshable state
- (void) setRefreshEnabled:(BOOL) refreshEnabled;

// Set refresh enabled, sometimes you need to switch refreshable state
- (void) setRefreshHeaderEnabled:(BOOL) refreshEnabled;

// Set refresh enabled, sometimes you need to switch refreshable state
- (void) setRefreshFooterEnabled:(BOOL) refreshEnabled;

// Refresh header callback
- (void) setRefreshHeaderCallback:(void (^)())refreshHeaderCallback;

// Refresh footer callback
- (void) setRefreshFooterCallback:(void (^)())refreshFooterCallback;

@end
