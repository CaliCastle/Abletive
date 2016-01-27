//
//  CommunityVIPCollectionViewCell.m
//  Abletive
//
//  Created by Cali on 11/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CommunityVIPCollectionViewCell.h"

@implementation CommunityVIPCollectionViewCell

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, [UIScreen mainScreen].bounds.size.width / 3);
    }
    return self;
}

@end
