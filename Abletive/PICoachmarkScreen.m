//
//  PICoachmarkScreen.m
//  NewPiki
//
//  Created by Pham Quy on 2/2/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import "PICoachmarkScreen.h"
#import "PICoachMarkProtocols.h"
#import "PIImageCoachmark.h"



@implementation PICoachmarkScreen
- (instancetype) initWithCoachMarks:(NSArray*) coachMarks
{
    self = [super init];
    if (self) {
        self.coachmarks = coachMarks;
    }
    return self;
}
@end

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/*
@{
  @"bgColor"  : @(0x000000),
  @"coachMarks" :
      @[
          @{
              @"viewRect": [NSValue valueWithCGRect:(CGRect){{0,0},{45,45}}],
              @"maskRect" : [NSValue valueWithCGRect:(CGRect){{0,0},{45,45}}],
              @"cuttingCornerRadius" : @(10.),
              @"imageName" : @"01 coachmark_home.gif",
              @"animated" : @(NO)
           }
        ],
  }
 */
@implementation PICoachmarkScreen (ImageCoachmark)
- (instancetype) initWithDictionary:(NSDictionary*) screenDict
{
    self = [super init];
    if (self) {
        NSArray* markDicts = [screenDict objectForKey:@"coachMarks"];

        if ([markDicts isKindOfClass:[NSArray class]]) {
            NSMutableArray* marks = [NSMutableArray arrayWithCapacity:markDicts.count];
            for (NSDictionary* markDict in markDicts) {
                id<PICoachmarkProtocol> coachMark = [[PIImageCoachmark alloc] initWithDictionary:markDict];
                [marks addObject:coachMark];
            }
            
            self.coachmarks = [NSArray arrayWithArray:marks];
        }
    }
    return self;
}
@end
