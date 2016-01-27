//
//  UIImage+Circle.h
//
//  Created by Cali on 15-6-16.
//

#import <UIKit/UIKit.h>

@interface UIImage (Circle)

// Clip image to be circlized
+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (UIImage *)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

// Scale the image to the specified size
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size;

@end




