//
//  TWRefreshView.h
//  EasyBaking
//
//  Created by Chris on 9/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWRefreshIndicator.h"

typedef NS_ENUM(NSInteger, TWRefreshViewType) {
    TWRefreshViewHeader,
    TWRefreshViewFooter,
};

typedef NS_ENUM(NSInteger, TWRefreshState) {
    TWRefreshStateNormal,
    TWRefreshStateReadyToRefresh,
    TWRefreshStateRefreshing,
};

@interface TWRefreshView : UIView

@property (nonatomic, assign) TWRefreshState state;

- (id) initWithType:(TWRefreshViewType) type;

// Refresh type
@property (nonatomic, assign)  TWRefreshViewType type;

//  Pulling refresh view
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

// Refresh indicator view
@property (nonatomic, assign) id<TWRefreshIndicator> indicator;

@end
