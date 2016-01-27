//
//  UIImage+Rounded.m
//  Abletive
//
//  Created by Cali on 6/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UIImage+Rounded.h"

@implementation UIImage (Rounded)

+ (UIImage *)roundedImageWithSize:(CGSize)size andBorderRadius:(CGFloat)radius forBackgroundColor:(UIColor *)bgColor {
    UIGraphicsBeginImageContext(size);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:radius];
    [bgColor setFill];
    [path fill];
    [path addClip];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

+ (UIImage *)roundedEdgeImageWithSize:(CGSize)size andBorderRadius:(CGFloat)radius withBorderWidth:(CGFloat)width forBorderColor:(UIColor *)strokeColor {
    UIGraphicsBeginImageContext(CGSizeMake(size.width+2*width, size.height+2*width));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(width, width, size.width, size.height) cornerRadius:radius];
    path.lineWidth = width;
    [strokeColor setStroke];
    [path stroke];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

@end
