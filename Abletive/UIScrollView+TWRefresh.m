//
//  UIScrollView+TWRefres.m
//  EasyBaking
//
//  Created by Chris on 12/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import "UIScrollView+TWRefresh.h"
#import <objc/runtime.h>

@interface UIScrollView ()
@property (nonatomic, strong) TWRefreshView *header;
@property (nonatomic, strong) TWRefreshView *footer;
@property (nonatomic, copy) void (^refreshHeaderCallback)();
@property (nonatomic, copy) void (^refreshFooterCallback)();
@end

static const NSString *TWRefreshHeaderKey = @"TWRefreshHeaderView";
static const NSString *TWRefreshFooterKey = @"TWRefreshFooterView";
static const NSString *TWRefreshHeaderCallbackKey = @"TWRefreshHeaderViewCallback";
static const NSString *TWRefreshFooterCallbackKey = @"TWRefreshFooterViewCallback";

@implementation UIScrollView (TWRefresh)

- (void) setHeader:(TWRefreshView *)header {
    objc_setAssociatedObject(self, &TWRefreshHeaderKey, header, OBJC_ASSOCIATION_RETAIN);
}

- (void) setFooter:(TWRefreshView *)footer {
    objc_setAssociatedObject(self, &TWRefreshFooterKey, footer, OBJC_ASSOCIATION_RETAIN);
}

- (TWRefreshView*) header {
    return objc_getAssociatedObject(self, &TWRefreshHeaderKey);
}

- (TWRefreshView*) footer {
    return objc_getAssociatedObject(self, &TWRefreshFooterKey);
}

- (void) setRefreshHeaderCallback:(void (^)())refreshHeaderCallback {
    objc_setAssociatedObject(self, &TWRefreshHeaderCallbackKey, refreshHeaderCallback, OBJC_ASSOCIATION_COPY);
}

- (void) setRefreshFooterCallback:(void (^)())refreshFooterCallback {
    objc_setAssociatedObject(self, &TWRefreshFooterCallbackKey, refreshFooterCallback, OBJC_ASSOCIATION_COPY);
}

- (void(^)()) refreshHeaderCallback {
    return objc_getAssociatedObject(self, &TWRefreshHeaderCallbackKey);
}

- (void(^)()) refreshFooterCallback {
    return objc_getAssociatedObject(self, &TWRefreshFooterCallbackKey);
}

- (void) setRefreshHeaderWithIndicatorClass:(Class)clazz {
    if ([clazz conformsToProtocol:@protocol(TWRefreshIndicator)]) {
        id<TWRefreshIndicator> indicator = [[clazz alloc] init];
        [self setRefreshHeaderIndicator:indicator];
    }
}

- (void) setRefreshHeaderIndicator:(id<TWRefreshIndicator>)indicator {
    if (!self.header) {
        TWRefreshView *refreshView = [[TWRefreshView alloc] initWithType:TWRefreshViewHeader];
        [self addSubview:refreshView];
        self.header = refreshView;
    }
    if (indicator) {
        [self.header setIndicator:indicator];
    }
}

- (void) setRefreshFooterWithIndicatorClass:(Class)clazz {
    if ([clazz conformsToProtocol:@protocol(TWRefreshIndicator)]) {
        id<TWRefreshIndicator> indicator = [[clazz alloc] init];
        [self setRefreshFooterIndicator:indicator];
    }
}

- (void) setRefreshFooterIndicator:(id<TWRefreshIndicator>)indicator {
    if (!self.footer) {
        TWRefreshView *refreshView = [[TWRefreshView alloc] initWithType:TWRefreshViewFooter];
        [self addSubview:refreshView];
        self.footer = refreshView;
    }
    if (indicator) {
        [self.footer setIndicator:indicator];
    }
}

- (void) refreshHeader {
    if (self.header) {
        [self.header setState:TWRefreshStateRefreshing];
    }
    if (self.refreshHeaderCallback) {
        self.refreshHeaderCallback();
    }
}

- (void) refreshFooter {
    if (self.footer) {
        [self.footer setState:TWRefreshStateRefreshing];
    }
    if (self.refreshFooterCallback) {
        self.refreshFooterCallback();
    }
}

- (void) stopHeaderRefreshing {
    if (self.header) {
        [self.header setState:TWRefreshStateNormal];
    }
}

- (void) stopFooterRefreshing {
    if (self.footer) {
        [self.footer setState:TWRefreshStateNormal];
    }
}

- (void) setRefreshEnabled:(BOOL)refreshEnabled {
    [self setRefreshHeaderEnabled:refreshEnabled];
    [self setRefreshFooterEnabled:refreshEnabled];
}

- (void) setRefreshHeaderEnabled:(BOOL)refreshEnabled {
    if (refreshEnabled) {
        if (self.header && !self.header.superview) {
            [self addSubview:self.header];
        }
    }
    else {
        if (self.header && self.header.superview==self) {
            // If is refreshing, stop it to adjust content inset
            [self.header setState:TWRefreshStateNormal];
            
            // Remove from self
            [self.header removeFromSuperview];
        }
    }
}

- (void) setRefreshFooterEnabled:(BOOL)refreshEnabled {
    if (refreshEnabled) {
        if (self.footer && !self.footer.superview) {
            [self addSubview:self.footer];
        }
    }
    else {
        if (self.footer && self.footer.superview==self) {
            // If is refreshing, stop it to adjust content inset
            [self.footer setState:TWRefreshStateNormal];
            
            // Remove from self
            [self.footer removeFromSuperview];
        }
    }
}

@end
