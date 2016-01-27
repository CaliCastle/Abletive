//
//  TWRefreshTableView.m
//  TWRefreshDemo
//
//  Created by Chris on 15/6/15.
//  Copyright (c) 2015 EasyBaking. All rights reserved.
//

#import "TWRefreshTableView.h"
#import "TWRefreshIndicatorView.h"

@implementation TWRefreshTableView
{
    BOOL _autoLoad;
    TWRefreshType _refreshType;
}

- (id) initWithFrame:(CGRect)frame refreshType:(TWRefreshType)type {
    return [self initWithFrame:frame refreshType:type andAutoLoad:YES];
}

- (id) initWithFrame:(CGRect)frame andAutoLoad:(BOOL) autoLoad {
    return [self initWithFrame:frame refreshType:TWRefreshTypeTop|TWRefreshTypeBottom andAutoLoad:autoLoad];
}

- (id) initWithFrame:(CGRect)frame refreshType:(TWRefreshType)type andAutoLoad:(BOOL) autoLoad {
    return [self initWithFrame:frame style:UITableViewStylePlain refreshType:type andAutoLoad:autoLoad];
}

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle) style refreshType:(TWRefreshType)type andAutoLoad:(BOOL) autoLoad {
    self = [super initWithFrame:frame style:style];
    if (self) {
        _refreshType = type;
        _autoLoad = autoLoad;
        [self prepareRefresh];
    }
    return self;
}

- (void) prepareRefresh {
    if((_refreshType & TWRefreshTypeTop) == TWRefreshTypeTop){
        [self setRefreshHeaderWithIndicatorClass:[TWRefreshIndicatorView class]];
    }
    if((_refreshType & TWRefreshTypeBottom) == TWRefreshTypeBottom){
        [self setRefreshFooterWithIndicatorClass:[TWRefreshIndicatorView class]];
    }
}

- (void) refreshHeader {
    [super refreshHeader];
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(beginRefreshHeader:)]) {
        [self.refreshDelegate beginRefreshHeader:self];
    }
}

- (void) refreshFooter {
    [super refreshFooter];
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(beginRefreshFooter:)]) {
        [self.refreshDelegate beginRefreshFooter:self];
    }
}

@end
