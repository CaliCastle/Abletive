//
//  PICoachMarkProtocols.h
//  NewPiki
//
//  Created by Pham Quy on 2/3/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PICoachmarkProtocol <NSObject>
@property (nonatomic) CGRect viewRect;
@property (nonatomic, strong) UIView* view;
- (void) start;
- (void) stop;
- (NSArray*) maskPaths;
@end
