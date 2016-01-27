//
//  PostHeaderView.m
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostHeaderView.h"

@interface PostHeaderView()

@property (nonatomic,strong) NSArray *posts;

@end

@implementation PostHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSArray *)posts {
    if (!_posts) {
        _posts = @[@"",@""];
    }
    return _posts;
}
- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        scrollView.contentSize = CGSizeMake(self.posts.count * frame.size.width, frame.size.height);
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:scrollView];
    }
    return self;
}

@end
