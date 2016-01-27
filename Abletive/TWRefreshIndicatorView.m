//
//  TWRefreshIndicaterView.m
//  EasyBaking
//
//  Created by Chris on 10/6/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import "TWRefreshIndicatorView.h"

@implementation TWRefreshIndicatorView
{
    CAShapeLayer *_arcLayer;
    UIImageView *_imageView;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addImageLayer];
        [self addShapeLayer];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self adjustShapeLayerPath];
}

- (void) start {
    [self startAnimation];
}

- (void) stop {
    [self removeAnimations];
}

- (void) pullingWithRatio:(CGFloat)ratio {
    [self drawLineAnimationWithRatio:ratio];
}

- (void) addImageLayer {
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator-center-icon"]];
    [self addSubview:_imageView];
}

- (void) removeAnimations {
    [_arcLayer removeAnimationForKey:@"pulling.refresh.rotation"];
    [_imageView.layer removeAnimationForKey:@"pulling.refresh.rotation"];
}

-(void) addShapeLayer {
    _arcLayer=[CAShapeLayer layer];
    _arcLayer.lineCap = kCALineCapRound;
    _arcLayer.lineJoin = kCALineJoinRound;
    _arcLayer.fillColor=[UIColor clearColor].CGColor;
    _arcLayer.strokeColor=[UIColor colorWithRed:202.0/255 green:96.0/255 blue:32.0/255 alpha:1.0].CGColor;
    _arcLayer.lineWidth=2;
    _arcLayer.strokeStart = 0;
    [self.layer addSublayer:_arcLayer];
}

- (void) adjustShapeLayerPath {
    if (_arcLayer) {
        _arcLayer.frame=self.bounds;
        UIBezierPath *path=[UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/2) radius:12 startAngle:-M_PI_2 endAngle:2*M_PI-M_PI_2 clockwise:YES];
        _arcLayer.path = path.CGPath;
    }
    if (_imageView) {
        _imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

-(void)drawLineAnimationWithRatio:(CGFloat) ratio {
    _arcLayer.strokeEnd = ratio;
}

- (void) startAnimation {
    // Remove animation first
    [self removeAnimations];
    
    // Add animation
    _arcLayer.strokeEnd = 0.94;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.fromValue = [NSNumber numberWithFloat:0.0];
    anim.toValue = [NSNumber numberWithFloat:2 * M_PI];
    anim.duration = 1.0;
    anim.repeatCount = INT_MAX;
    [_arcLayer addAnimation:anim forKey:@"pulling.refresh.rotation"];
    anim.toValue = [NSNumber numberWithFloat:-2*M_PI];
    [_imageView.layer addAnimation:anim forKey:@"pulling.refresh.rotation"];
}

@end
