//
//  MeGuestHeaderView.m
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MeGuestHeaderView.h"
#import "MeGuestHeaderViewController.h"


@interface MeGuestHeaderView()

@end

@implementation MeGuestHeaderView

- (void)awakeFromNib {
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIGraphicsBeginImageContext(self.frame.size);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, -self.frame.size.height * 3) radius:self.frame.size.height * 3.7 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    path.lineWidth = 5;
    [[UIColor colorWithRed:181/255.0 green:51/255.0 blue:43/255.0 alpha:1]setFill];
    [path fill];
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.frame];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    backgroundView.image = backgroundImage;
    
    UIGraphicsEndImageContext();
    
    [self insertSubview:backgroundView atIndex:0];
}

@end
