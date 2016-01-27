//
//  PICoachMark.h
//  NewPiki
//
//  Created by Pham Quy on 2/2/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PICoachMarkProtocols.h"



@interface PIImageCoachmark : NSObject <PICoachmarkProtocol>
- (instancetype) initWithDictionary:(NSDictionary*) dictionary;
@property (nonatomic) CGFloat duration;
@property (nonatomic) NSInteger repeatCount;
@end
