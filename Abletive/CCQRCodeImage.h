//
//  CCQRCodeImage.h
//  Abletive
//
//  Created by Cali on 11/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCQRCodeImage : UIImage

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;
+ (CIImage *)createQRForString:(NSString *)qrString;
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
