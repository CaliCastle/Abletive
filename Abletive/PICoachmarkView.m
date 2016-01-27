//
//  PICoachmarkView.m
//  NewPiki
//
//  Created by Pham Quy on 2/2/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import "PICoachmarkView.h"
#import "PIImageCoachmark.h"
#import "PICoachmarkScreen.h"
static const CGFloat kAnimationDuration = 0.3f;
//static const CGFloat kCutoutRadius = 2.0f;
//static const CGFloat kMaxLblWidth = 230.0f;
//static const CGFloat kLblSpacing = 35.0f;
//static const BOOL kEnableContinueLabel = YES;
//static const BOOL kEnableSkipButton = YES;


@interface PICoachmarkView()

@property (nonatomic, strong) CAShapeLayer *mask;
@property (nonatomic)         PICoachmarkScreen* currentScreen;


@end

@implementation PICoachmarkView
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationDuration = kAnimationDuration;
        // Mask
        _mask = [CAShapeLayer layer];
        [_mask setFillRule:kCAFillRuleEvenOdd];
        [_mask setFillColor:[[UIColor colorWithWhite:0.0f alpha:0.7f] CGColor]];
        [self.layer addSublayer:_mask];
        
        // Capture touches
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(userDidTap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        
        self.hidden = YES;

    }
    return self;
}
//------------------------------------------------------------------------------
- (void) start
{
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    PICoachmarkScreen* screen = [self.screens objectAtIndex:0];
//    [UIView animateWithDuration:self.animationDuration
//                     animations:^{
//                         self.alpha = 1.0f;
//                     }
//                     completion:^(BOOL finished) {
//                         // Go to the first coach mark
//                         [self showCoachmarkScreen: screen];
//                     }];
     self.alpha = 1.0f;
    [self showCoachmarkScreen: screen];
}
//------------------------------------------------------------------------------
- (void) skipCoaching
{
    [self cleanup];
}

//------------------------------------------------------------------------------
- (void)addScreen:(PICoachmarkScreen *)screen
{
    NSMutableArray* screens = self.screens ? [self.screens mutableCopy] : [NSMutableArray array];
    [screens addObject: screen];
    self.screens = [NSArray arrayWithArray:screens];
}

//------------------------------------------------------------------------------
#pragma mark - Touch handler
- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    
    NSInteger currentScreenIdx = [self.screens indexOfObject:self.currentScreen];
    if (currentScreenIdx < (self.screens.count - 1)) {
        [self showCoachmarkScreen:[self.screens objectAtIndex:currentScreenIdx+1]];
    }else{
        [self cleanup];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Coaching
- (void)showCoachmarkScreen:(PICoachmarkScreen*) screen
{
    if (!screen) {
        return;
    }
    
    NSInteger toIndex = [self.screens indexOfObject:screen];
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:toIndex];
    }
    [self transitFromScreen:self.currentScreen toScreen:screen];
}

//------------------------------------------------------------------------------
- (void) transitFromScreen:(PICoachmarkScreen*) fromScreen toScreen:(PICoachmarkScreen*) toScreen
{
    UIBezierPath* toMaskPath    = [self maskPathForScreen: toScreen];
    UIBezierPath* fromMaskPath  = [self maskPathForScreen:fromScreen];
    fromMaskPath = fromMaskPath? fromMaskPath:toMaskPath;
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(fromMaskPath.CGPath);
    anim.toValue = (__bridge id)(toMaskPath.CGPath);
    [_mask addAnimation:anim forKey:@"path"];
    _mask.path = toMaskPath.CGPath;

    
    if (toScreen) {
        for (id<PICoachmarkProtocol> mark in toScreen.coachmarks) {
            [mark.view setFrame: mark.viewRect];
            [mark.view setAlpha:0.0f];
            [self addSubview:mark.view];
        }
    }

    if (fromScreen) {
        for (id<PICoachmarkProtocol> mark in fromScreen.coachmarks) {
            [mark stop];
            [mark.view removeFromSuperview];
        }
    }
    
    [UIView
     animateWithDuration:self.animationDuration
     animations:^{
         if (toScreen) {
             for (id<PICoachmarkProtocol> mark in toScreen.coachmarks) {
                 //[mark.view.layer setFrame: mark.viewRect];
                 [mark.view setAlpha:1.0f];
             }
         }
     }
     completion:^(BOOL finished) {

         
         if (toScreen) {
             for (id<PICoachmarkProtocol> mark in toScreen.coachmarks) {
                 //[mark.view.layer setFrame: mark.viewRect];
                 [mark start];
             }
         }
     }];
    
    _currentScreen = toScreen;
}


//------------------------------------------------------------------------------
- (UIBezierPath*) maskPathForScreen:(PICoachmarkScreen*) screen
{
    if (!screen) {
        return nil;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    for (id<PICoachmarkProtocol> mark in screen.coachmarks) {
        NSArray* paths= [mark maskPaths];
        for (UIBezierPath* path in paths) {
            [maskPath appendPath:path];
        }
    }
    return maskPath;
}
//------------------------------------------------------------------------------
- (void) cleanup
{
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillFinish:)]) {
        [self.delegate coachMarksViewWillFinish:self];
    }
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidFinish:)]) {
                             [self.delegate coachMarksViewDidFinish:self];
                         }
                     }];

}


//------------------------------------------------------------------------------
#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:[self.screens indexOfObject:self
                                                               .currentScreen]];
    }
}
@end



//------------------------------------------------------------------------------
#pragma mark - PICoachmarkView (ImageCoachmark)
//------------------------------------------------------------------------------

@implementation  PICoachmarkView (ImageCoachmark)

- (instancetype) initWithFrame:(CGRect) frame
                    coachMarks:(NSDictionary*) coachMarkDicts
{
    self = [super initWithFrame:frame];
    if (self) {
        if(![self setupWithData:coachMarkDicts])
        {
            self = nil;
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (BOOL) setupWithData:(NSDictionary*)coachMarkDicts
{
    
    
    if (coachMarkDicts[@"animationDuration"]) {
        self.animationDuration = [coachMarkDicts[@"animationDuration"] floatValue];
    }else{
        self.animationDuration = kAnimationDuration;
    }
    
    //    if (coachMarkDicts[@"interactive"]) {
    //        self.interactive = [coachMarkDicts[@"interactive"] boolValue];
    //    }else{
    //        self.interactive = YES;
    //    }
    
    
    // Reporing failed setup if no valid coach screens
    if (!coachMarkDicts[@"coachScreens"]) {
        return NO;
    }
    
    NSArray* coachScreenDicts = coachMarkDicts[@"coachScreens"];
    if (![coachScreenDicts isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    
    NSMutableArray* coachMarkScreens = [NSMutableArray
                                        arrayWithCapacity:coachScreenDicts.count];
    
    for (NSDictionary* screenDict in coachScreenDicts) {
        PICoachmarkScreen* screen = [[PICoachmarkScreen alloc] initWithDictionary:screenDict];
        [coachMarkScreens addObject:screen];
    }
    
    
    // Report failed setup
    if (!coachMarkScreens.count) {
        return NO;
    }
    
    self.screens = [NSArray arrayWithArray:coachMarkScreens];
    
    self.animationDuration = kAnimationDuration;
    // Mask
    _mask = [CAShapeLayer layer];
    [_mask setFillRule:kCAFillRuleEvenOdd];
    [_mask setFillColor:[[UIColor colorWithWhite:0.0f alpha:0.7f] CGColor]];
    [self.layer addSublayer:_mask];
    
    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    
    self.hidden = YES;
    
    return YES;
}

@end
