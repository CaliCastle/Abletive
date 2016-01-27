//
//  CCGradientView.h
//  Abletive
//
//  Created by Cali on 10/10/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCGradientView : UIView

@property (nonatomic,strong) UIColor *mainColor;

- (instancetype)initWithFrame:(CGRect)frame andMainColor:(UIColor *)mainColor;

@end
