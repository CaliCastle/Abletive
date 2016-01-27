//
//  TWRefreshView.m
//  EasyBaking
//
//  Created by Chris on 9/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import "TWRefreshView.h"
#import "UIScrollView+TWRefresh.h"

#define TWRefreshContentOffsetKeyPath @"contentOffset"
#define TWRefreshContentInsetKeyPath @"contentInset"
#define TWRefreshContentSizeKeyPath @"contentSize"

#define TWRefreshHeaderViewHeight 54
#define TWRefreshFooterViewHeight 49

// Refresh state, view type, indicator
@interface TWRefreshView ()
- (void) setState:(TWRefreshState)state;
- (void) setType:(TWRefreshViewType)type;
- (void) setIndicator:(id<TWRefreshIndicator>)indicator;
@end

// Observers
@interface TWRefreshView (ObserverMethods)
- (void) addObservers;
- (void) removeObservers;
@end

// Layout refresh view,
@interface TWRefreshView (InnerMethods)
- (void) layout;
@end

@implementation TWRefreshView
{
    UIScrollView *_scrollView;
    __unsafe_unretained id<TWRefreshIndicator> _indicator;
    TWRefreshViewType _type;
    TWRefreshState _state;
    
    UIEdgeInsets _originalContentInsets;
}

- (id) initWithType:(TWRefreshViewType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self layout];
}

- (UIScrollView*) scrollView {
    return _scrollView;
}

- (void) willMoveToSuperview:(UIView *)newSuperview {
    // Call super method
    [super willMoveToSuperview:newSuperview];
    
    // Check super view tye
    if (!newSuperview || ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    _scrollView = (UIScrollView*)newSuperview;
    
    // Work around, just get the correct original content insets
    [self performSelector:@selector(initOriginalContentOffset) withObject:nil afterDelay:0.01];
    
    CGRect r = self.frame;
    r.origin.x = 0;
    r.size.width = newSuperview.frame.size.width;
    self.frame = r;
    
    // If has super view
    if (self.superview) {
        [self removeObservers];
    }
    
    // Add required observers
    [self addObservers];
}

- (void) initOriginalContentOffset {
    _originalContentInsets = _scrollView.contentInset;
}

- (void) removeFromSuperview {
    [self removeObservers];
    [super removeFromSuperview];
}

- (void) setIndicator:(id<TWRefreshIndicator>)indicator {
    if(_indicator != indicator) {
        _indicator = indicator;
        if ([indicator isKindOfClass:[UIView class]]) {
            [self addSubview:(UIView*)indicator];
        }
    }
}

- (void) setType:(TWRefreshViewType)type {
    _type = type;
    [self setNeedsLayout];
}

- (void) setState:(TWRefreshState)state {
    if (state==_state) {
        return;
    }
    _state = state;
    if (state==TWRefreshStateRefreshing) {
        // Set content inset
        if (_type==TWRefreshViewHeader) {
            UIEdgeInsets edgeInset = _scrollView.contentInset;
            edgeInset.top = self.frame.size.height + _originalContentInsets.top;
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentInset = edgeInset;
            } completion:^(BOOL finished) {
            }];
        }
        else if (_type==TWRefreshViewFooter) {
            UIEdgeInsets edgeInset = _scrollView.contentInset;
            edgeInset.bottom = self.frame.size.height+_originalContentInsets.bottom+MAX(_scrollView.frame.size.height-_originalContentInsets.top-_originalContentInsets.bottom-_scrollView.contentSize.height, 0);
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentInset = edgeInset;
            } completion:^(BOOL finished) {
            }];
        }
        
        // Start indicator
        if ([_indicator respondsToSelector:@selector(start)]) {
            [_indicator start];
        }
    }
    else if (state==TWRefreshStateNormal) {
        // Set content inset
        if (_type==TWRefreshViewHeader) {
            UIEdgeInsets edgeInset = _scrollView.contentInset;
            // Fix inset issue, when scroll view is refresh, and push another view controller
            edgeInset.top -= self.frame.size.height;//_originalContentInsets.top;
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentInset = edgeInset;
            } completion:^(BOOL finished) {
                
            }];
        }
        else if (_type==TWRefreshViewFooter) {
            UIEdgeInsets edgeInset = _scrollView.contentInset;
            // Fix inset issue, when scroll view is refresh, and push another view controller
            edgeInset.bottom -= self.frame.size.height;//_originalContentInsets.bottom;
            
            // If scroll view content size height less than it's frame
            edgeInset.bottom -= MAX(_scrollView.frame.size.height-_originalContentInsets.top-_originalContentInsets.bottom-_scrollView.contentSize.height, 0);
            
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentInset = edgeInset;
            } completion:^(BOOL finished) {
            }];
        }
        
        // Start indicator
        if ([_indicator respondsToSelector:@selector(stop)]) {
            [_indicator stop];
        }
    }
}

@end

@implementation TWRefreshView (ObserverMethods)

- (void) addObservers {
    [_scrollView addObserver:self forKeyPath:TWRefreshContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:TWRefreshContentInsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:TWRefreshContentSizeKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void) removeObservers {
    [self.superview removeObserver:self forKeyPath:TWRefreshContentOffsetKeyPath];
    [self.superview removeObserver:self forKeyPath:TWRefreshContentInsetKeyPath];
    [self.superview removeObserver:self forKeyPath:TWRefreshContentSizeKeyPath];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([TWRefreshContentOffsetKeyPath isEqualToString:keyPath]) {
        [self contentOffsetChanged:change];
    }
    else if ([TWRefreshContentInsetKeyPath isEqualToString:keyPath]) {
        [self contentInsetChanged:change];
    }
    else if ([TWRefreshContentSizeKeyPath isEqualToString:keyPath]) {
        [self contentSizeChanged:change];
    }
}

- (void) contentOffsetChanged:(NSDictionary*) change {
    if (_state==TWRefreshStateRefreshing) {
        return;
    }
    
    // Correct content inset firstly set here, assignment in willMoveToSuperView not work infact
    //_originalContentInsets = _scrollView.contentInset;
    
    CGPoint contentOffset = _scrollView.contentOffset;
    if (_scrollView.isDragging) {
        CGFloat ratio = 0;
        BOOL invokeRatio = NO;
        if (_type==TWRefreshViewHeader) {
            CGFloat offsetY = contentOffset.y+_originalContentInsets.top;
            if (offsetY<=-self.frame.size.height) {
                _state = TWRefreshStateReadyToRefresh;
            }
            else {
                _state = TWRefreshStateNormal;
            }
            if (offsetY<0) {
                ratio = MAX(0, MIN(-offsetY/self.frame.size.height, 1.0));
                invokeRatio = YES;
            }
        }
        else if (_type==TWRefreshViewFooter) {
            CGFloat offsetY = contentOffset.y+_originalContentInsets.top;
            CGFloat beginY = MAX(_scrollView.contentSize.height-_scrollView.frame.size.height+_originalContentInsets.top+_originalContentInsets.bottom, 0);
            if (offsetY>=beginY+self.frame.size.height) {
                _state = TWRefreshStateReadyToRefresh;
            }
            else {
                _state = TWRefreshStateNormal;
            }
            if (offsetY>beginY) {
                ratio = MAX(0, MIN((offsetY-beginY)/self.frame.size.height, 1.0));
                invokeRatio = YES;
            }
        }
        if (invokeRatio && [_indicator respondsToSelector:@selector(pullingWithRatio:)]) {
            [_indicator pullingWithRatio:ratio];
        }
    }
    else {
        if (_type==TWRefreshViewHeader) {
            if (_state==TWRefreshStateReadyToRefresh) {
                [_scrollView refreshHeader];
            }
        }
        else if (_type==TWRefreshViewFooter) {
            if (_state==TWRefreshStateReadyToRefresh) {
                [_scrollView refreshFooter];
            }
        }
    }
}

- (void) contentInsetChanged:(NSDictionary*) change {
    [self layout];
}

- (void) contentSizeChanged:(NSDictionary*) change {
    [self layout];
}

@end

@implementation TWRefreshView (InnerMethods)

- (void) layout {
    CGRect r = self.frame;
    switch (_type) {
        case TWRefreshViewHeader:
        {
            r.size.height = TWRefreshHeaderViewHeight;
            r.origin.y = -r.size.height;
            break;
        }
        case TWRefreshViewFooter:
        {
            r.size.height = TWRefreshFooterViewHeight;
            r.origin.y = MAX(_scrollView.contentSize.height, _scrollView.frame.size.height-_originalContentInsets.top-_originalContentInsets.bottom);
            break;
        }
        default:
            break;
    }
    self.frame = r;
    if (_indicator) {
        ((UIView*)_indicator).frame = self.bounds;
    }
}

@end
