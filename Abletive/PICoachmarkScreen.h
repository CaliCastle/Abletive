//
//  PICoachmarkScreen.h
//  NewPiki
//
//  Created by Pham Quy on 2/2/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PICoachmarkScreen : NSObject
@property (nonatomic, strong) NSArray* coachmarks;
- (instancetype) initWithCoachMarks:(NSArray*) coachMarks;
@end


@interface PICoachmarkScreen (ImageCoachmark)
- (instancetype) initWithDictionary:(NSDictionary*) screenDict;
@end