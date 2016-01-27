//
//  TWRefreshIndicator.h
//  EasyBaking
//
//  Created by Chris on 10/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWRefreshIndicator <NSObject>

@optional
- (void) start;
- (void) stop;
- (void) pullingWithRatio:(CGFloat) ratio;

@end
