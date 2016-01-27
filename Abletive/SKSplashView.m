//
//  SKSplashView.m
//  SKSplashView
//
//  Created by Sachin Kesiraju on 10/25/14.
//  Copyright (c) 2014 Sachin Kesiraju. All rights reserved.
//

#import "SKSplashView.h"
#import "SKSplashIcon.h"

@interface SKSplashView()

@property (nonatomic, assign) SKSplashAnimationType animationType;
@property (nonatomic, assign) SKSplashIcon *splashIcon;
@property (strong, nonatomic) CAAnimation *customAnimation;

@end

@implementation SKSplashView

#pragma mark - Instance methods

- (instancetype)initWithAnimationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _animationType = animationType;
    }
    
    return self;
}

- (instancetype) initWithBackgroundColor:(UIColor *)backgroundColor animationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _backgroundViewColor = backgroundColor;
        self.backgroundColor = backgroundColor;
        _animationType = animationType;
    }
    
    return self;
}

- (instancetype) initWithBackgroundImage:(UIImage *)backgroundImage animationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _backgroundImage = backgroundImage;
        _animationType = animationType;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
    }
    
    return self;
}

- (instancetype) initWithSplashIcon:(SKSplashIcon *)icon animationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _splashIcon = icon;
        _animationType = animationType;
        self.backgroundColor = [self setBackgroundViewColor];
        icon.center = self.center;
        [self addSubview:icon];
    }
    
    return self;
}

- (instancetype) initWithSplashIcon:(SKSplashIcon *)icon backgroundColor:(UIColor *)backgroundColor animationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _splashIcon = icon;
        _backgroundViewColor = backgroundColor;
        _animationType = animationType;
        icon.center = self.center;
        self.backgroundColor = _backgroundViewColor;
        [self addSubview:icon];
    }
    return self;
}

- (instancetype) initWithSplashIcon:(SKSplashIcon *)icon backgroundImage:(UIImage *)backgroundImage animationType:(SKSplashAnimationType)animationType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        _splashIcon = icon;
        _backgroundImage = backgroundImage;
        _animationType = animationType;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        [self addSubview:icon];
    }
    return self;
}

#pragma mark - Public methods

- (void)startAnimation;
{
    if(_splashIcon)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f",self.animationDuration] forKey:@"animationDuration"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startAnimation" object:self userInfo:dic];
    }
    if([self.delegate respondsToSelector:@selector(splashView:didBeginAnimatingWithDuration:)])
    {
        [self.delegate splashView:self didBeginAnimatingWithDuration:self.animationDuration];
    }
    
    switch(_animationType)
    {
        case SKSplashAnimationTypeBounce:
            [self addBounceAnimation];
            break;
        case SKSplashAnimationTypeFade:
            [self addFadeAnimation];
            break;
        case SKSplashAnimationTypeZoom:
            [self addZoomAnimation];
            break;
        case SKSplashAnimationTypeShrink:
            [self addShrinkAnimation];
            break;
        case SKSplashAnimationTypeNone:
            [self addNoAnimation];
            break;
        case SKSplashAnimationTypeCustom:
            if(_animationType)
            {
                [self addCustomAnimationWithAnimation:_customAnimation];
            }
            else
            {
                [self addCustomAnimationWithAnimation:[self customAnimation]];
            }
            break;
        default:NSLog(@"No animation type selected");
            break;
    }
}

- (void) setCustomAnimationType:(CAAnimation *)animation
{
    _customAnimation = animation;
}

- (void) setBackgroundImage:(UIImage *)backgroundImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    imageView.frame = [UIScreen mainScreen].bounds;
    [self addSubview:imageView];
}

#pragma mark - Property setters

- (CGFloat)animationDuration
{
    if (!_animationDuration) {
        _animationDuration = 1.0f;
    }
    return _animationDuration;
}

- (CAAnimation *)customAnimation
{
    if (!_animationType) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@1, @0.9, @300];
        animation.keyTimes = @[@0, @0.4, @1];
        animation.duration = self.animationDuration;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        _customAnimation = animation;
    }
    return _customAnimation;
}

- (UIColor *) setBackgroundViewColor
{
    if (!_backgroundViewColor) {
        _backgroundViewColor = [UIColor whiteColor];
    }
    return _backgroundViewColor;
}

#pragma mark - Animations

- (void) addBounceAnimation
{
    CGFloat bounceDuration = self.animationDuration * 0.8;
    [NSTimer scheduledTimerWithTimeInterval:bounceDuration target:self selector:@selector(pingGrowAnimation) userInfo:nil repeats:NO];
}

- (void) pingGrowAnimation
{
    CGFloat growDuration = self.animationDuration *0.2;
    [UIView animateWithDuration:growDuration animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(20, 20);
        self.transform = scaleTransform;
        self.alpha = 0;
        self.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self endAnimating];
    }];
}

- (void) growAnimation
{
    CGFloat growDuration = self.animationDuration * 0.7;
    [UIView animateWithDuration:growDuration animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(20, 20);
        self.transform = scaleTransform;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self endAnimating];
    }];
}

- (void) addFadeAnimation
{
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self endAnimating];
    }];

}

- (void) addShrinkAnimation
{
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.5, 0.5);
        self.transform = scaleTransform;
        self.alpha = 0;
    }completion:^(BOOL finished)
     {
         [self removeFromSuperview];
         [self endAnimating];
     }];
}

- (void) addZoomAnimation
{
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(10, 10);
        self.transform = scaleTransform;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self endAnimating];
    }];
}

- (void) addNoAnimation
{
    [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(removeSplashView) userInfo:nil repeats:NO];
}

- (void) addCustomAnimationWithAnimation: (CAAnimation *) animation
{
    [self.layer addAnimation:animation forKey:@"SKSplashAnimation"];
    [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(removeSplashView) userInfo:nil repeats:YES];
}

- (void) removeSplashView
{
    [self removeFromSuperview];
    [self endAnimating];
}

- (void) endAnimating
{
    if([self.delegate respondsToSelector:@selector(splashViewDidEndAnimating:)])
    {
        [self.delegate splashViewDidEndAnimating:self];
    }
}

@end
