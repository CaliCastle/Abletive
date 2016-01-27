//
//  CCGradientView.m
//  Abletive
//
//  Created by Cali on 10/10/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CCGradientView.h"

@implementation CCGradientView


- (instancetype)initWithFrame:(CGRect)frame andMainColor:(UIColor *)mainColor {
    if (self = [super initWithFrame:frame]) {
        self.mainColor = mainColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient;
    int location_num = 3;
    
    CGColorRef color = self.mainColor.CGColor;
    CGFloat colors[4] = {0,0,0,0};
    for (int i = 0; i<4; i++) {
        colors[i] = CGColorGetComponents(color)[i];
    }
    
    CGFloat components[] = {colors[0],colors[1],colors[2],0,
        colors[0],colors[1],colors[2],0.35,
        colors[0],colors[1],colors[2],1};
    
    CGFloat locations[] = {0,0.6,1};
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, location_num);
    CGContextDrawLinearGradient(context, myGradient, CGPointMake(0, 0),CGPointMake(0, rect.size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = rect;
    imageView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:imageView];
    
    UIGraphicsEndImageContext();
}


@end
