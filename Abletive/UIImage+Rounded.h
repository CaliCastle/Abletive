//
//  UIImage+Rounded.h
//  Abletive
//
//  Created by Cali on 6/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rounded)

+ (UIImage *)roundedImageWithSize:(CGSize)size andBorderRadius:(CGFloat)radius forBackgroundColor:(UIColor *)bgColor;
+ (UIImage *)roundedEdgeImageWithSize:(CGSize)size andBorderRadius:(CGFloat)radius withBorderWidth:(CGFloat)width forBorderColor:(UIColor *)strokeColor;

@end
