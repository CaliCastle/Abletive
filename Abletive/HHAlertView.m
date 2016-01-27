//
//  MrLoadingView.m
//  MrLoadingView
//
//  Created by ChenHao on 2/11/15.
//  Copyright (c) 2015 xxTeam. All rights reserved.
//  Modified by Cali on 18/06/15.

#import "HHAlertView.h"
#import "AppColor.h"


#define OKBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:255/255.0 green:20/255.0 blue:20/255.0 alpha:1]
#define CANCELBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:200/255.0 green:152/255.0 blue:0.0 alpha:1]


NSInteger const Mralertview_SIZE_WIDTH = 260;
NSInteger const Mralertview_SIZE_HEIGHT = 250;
NSInteger const Simble_SIZE      = 60;
NSInteger const Simble_TOP      = 35;

NSInteger const Button_SIZE_WIDTH        = 100;
NSInteger const Buutton_SIZE_HEIGHT      = 40;



NSInteger const Mralertview_SIZE_TITLE_FONT = 20;
NSInteger const Mralertview_SIZE_DETAIL_FONT = 16;

static selectButton STAblock;


@interface HHAlertView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *OkButton;

@property (nonatomic, strong) UIView *logoView;

@end


@implementation HHAlertView



+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    static HHAlertView *alert;
    dispatch_once(&once, ^{
        alert = [[HHAlertView alloc] init];
    });
    return alert;
}



- (instancetype)init
{
    self = [[HHAlertView alloc] initWithFrame:CGRectMake(([self getMainScreenSize].width-Mralertview_SIZE_WIDTH)/2, ([self getMainScreenSize].height-Mralertview_SIZE_HEIGHT)/2, Mralertview_SIZE_WIDTH, Mralertview_SIZE_HEIGHT)];
    self.alpha = 0;
    [self setBackgroundColor:[AppColor secondaryBlack]];
    
    return self;
}


+ (void)showAlertWithStyle:(HHAlertStyle )HHAlertStyle inView:(UIView *)view Title:(NSString *)title detail:(NSString *)detail cancelButton:(NSString *)cancel Okbutton:(NSString *)ok
{
    
    switch (HHAlertStyle) {
        case HHAlertStyleDefault:
        {
            [[self shared] drawTick];
        }
            break;
        case HHAlertStyleError:
        {
            [[self shared] drawError];
        }
            break;
        case HHAlertStyleOk:
        {
            [[self shared] drawTick];
        }
            break;
        case HHAlertStyleWarning:
        {
            [[self shared] drawWarning];
        }
            break;
            
        default:
            break;
    }
    
    
    [[self shared] configtextWithStyle:HHAlertStyle andTitle:title detail:detail];
    
    
    [[self shared] configButton:cancel Okbutton:ok];
    
    [view addSubview:[self shared]];
    [[self shared] show];
}



+ (void)showAlertWithStyle:(HHAlertStyle)HHAlertStyle inView:(UIView *)view Title:(NSString *)title detail:(NSString *)detail cancelButton:(NSString *)cancel Okbutton:(NSString *)ok block:(selectButton)block
{
 
    STAblock = block;
    switch (HHAlertStyle) {
        case HHAlertStyleDefault:
        {
            [[self shared] drawTick];
        }
            break;
        case HHAlertStyleError:
        {
            [[self shared] drawError];
        }
            break;
        case HHAlertStyleOk:
        {
            [[self shared] drawTick];
        }
            break;
        case HHAlertStyleWarning:
        {
            [[self shared] drawWarning];
        }
            break;
            
        default:
            break;
    }
    
    
    [[self shared] configtextWithStyle:HHAlertStyle andTitle:title detail:detail];
    
    
    [[self shared] configButton:cancel Okbutton:ok];
    
    [view addSubview:[self shared]];
    [[self shared] show];
    
}



- (void)configtextWithStyle:(HHAlertStyle)alertStyle andTitle:(NSString *)title detail:(NSString *)detail
{
    if (_titleLabel==nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Simble_SIZE+Simble_TOP+15, [self getSelfSize].width, Mralertview_SIZE_TITLE_FONT+5)];
    }
    
    _titleLabel.text = title;
    [_titleLabel setFont:[UIFont systemFontOfSize:Mralertview_SIZE_TITLE_FONT]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    switch (alertStyle) {
        case HHAlertStyleDefault:
            [_titleLabel setTextColor:[AppColor mainWhite]];
            break;
        case HHAlertStyleError:
            [_titleLabel setTextColor:[AppColor mainRed]];
            break;
        case HHAlertStyleOk:
            [_titleLabel setTextColor:[AppColor mainWhite]];
            break;
        case HHAlertStyleWarning:
            [_titleLabel setTextColor:[AppColor mainYellow]];
        default:
            break;
    }
    
    [self addSubview:_titleLabel];
    
    if (_detailLabel==nil) {
        _detailLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, Simble_SIZE+Simble_TOP+Mralertview_SIZE_TITLE_FONT+25, [self getSelfSize].width, Mralertview_SIZE_TITLE_FONT)];
    }
    
    _detailLabel.text = detail;
    _detailLabel.textColor = [UIColor grayColor];
    _detailLabel.numberOfLines = 2;
    [_detailLabel setFont:[UIFont systemFontOfSize:Mralertview_SIZE_DETAIL_FONT]];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_detailLabel];
    
}


- (void)configButton:(NSString *)cancel Okbutton:(NSString *)ok
{
    if (cancel==nil) {
        if (_OkButton==nil) {
            _OkButton = [[UIButton alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Button_SIZE_WIDTH)/2, [self getSelfSize].height-Buutton_SIZE_HEIGHT-10, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
        }
        else
        {
            [_OkButton setFrame:CGRectMake(([self getSelfSize].width-Button_SIZE_WIDTH)/2, [self getSelfSize].height-Buutton_SIZE_HEIGHT-10, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
        }
        
        [_OkButton setTitle:ok forState:UIControlStateNormal];
        [_OkButton setBackgroundColor:OKBUTTON_BACKGROUND_COLOR];
        [[_OkButton layer] setCornerRadius:5];
     
        [_OkButton addTarget:self action:@selector(dismissWithOk) forControlEvents:UIControlEventTouchUpInside];

        
        
        [self addSubview:_OkButton];
        
    }
    
    
    if (cancel!=nil && ok!=nil) {
        if (_cancelButton == nil) {
            _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(([self getSelfSize].width/2-100)/2, [self getSelfSize].height-Buutton_SIZE_HEIGHT-10, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
        }
        
        [_cancelButton setBackgroundColor:CANCELBUTTON_BACKGROUND_COLOR];
        [_cancelButton setTitle:cancel forState:UIControlStateNormal];
        [[_cancelButton layer] setCornerRadius:5];
        [_cancelButton addTarget:self action:@selector(dismissWithCancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        
        
        if (_OkButton==nil) {
            _OkButton = [[UIButton alloc] initWithFrame:CGRectMake(([self getSelfSize].width/2-100)/2+[self getSelfSize].width/2, [self getSelfSize].height-Buutton_SIZE_HEIGHT-10, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
        }
        else
        {
            [_OkButton setFrame:CGRectMake(([self getSelfSize].width/2-100)/2+[self getSelfSize].width/2, [self getSelfSize].height-Buutton_SIZE_HEIGHT-10, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
        }
        
        [_OkButton setTitle:ok forState:UIControlStateNormal];
        [_OkButton setBackgroundColor:OKBUTTON_BACKGROUND_COLOR];
        [[_OkButton layer] setCornerRadius:5];
        [_OkButton addTarget:self action:@selector(dismissWithOk) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_OkButton];
    }
}

- (void)dismissWithCancel
{
    
    if (STAblock!=nil) {
        STAblock(HHAlertButtonCancel);
    }
    else
    {
        [_delegate didClickButtonAnIndex:HHAlertButtonCancel];
    }
    [HHAlertView Hide];
}

- (void)dismissWithOk
{
    
    if (STAblock!=nil) {
        STAblock(HHAlertButtonOk);
    }
    else
    {
        [_delegate didClickButtonAnIndex:HHAlertButtonOk];
    }
    [HHAlertView Hide];
}


- (void)destroy
{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0;
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 10.0f;
    } completion:^(BOOL finished) {
        [_OkButton removeFromSuperview];
        [_cancelButton removeFromSuperview];
        _OkButton=nil;
        _cancelButton = nil;
        STAblock=nil;
        [self removeFromSuperview];
    }];
}



- (void)show
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=1;
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 10.0f;
    } completion:^(BOOL finished) {
        
    }];
    
}


+ (void)Hide
{
    [[self shared] destroy];
}


#pragma helper mehtod

- (CGSize)getMainScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

- (CGSize)getSelfSize
{
    return self.frame.size;
}


#pragma draw method

- (void)drawError
{
    [_logoView removeFromSuperview];
    _logoView = [[UIView alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Simble_SIZE)/2, Simble_TOP, Simble_SIZE, Simble_SIZE)];
    
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/2) radius:Simble_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    CGPoint p1 =  CGPointMake(Simble_SIZE/4, Simble_SIZE/4);
    [path moveToPoint:p1];
    
    CGPoint p2 =  CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4*3);
    [path addLineToPoint:p2];
    
    CGPoint p3 =  CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4);
    [path moveToPoint:p3];
    
    CGPoint p4 =  CGPointMake(Simble_SIZE/4, Simble_SIZE/4*3);
    [path addLineToPoint:p4];
    
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 5;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
    [self addSubview:_logoView];
}


- (void)drawTick
{
    
    [_logoView removeFromSuperview];
    _logoView = [[UIView alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Simble_SIZE)/2, Simble_TOP, Simble_SIZE, Simble_SIZE)];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/2) radius:Simble_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    [path moveToPoint:CGPointMake(Simble_SIZE/4, Simble_SIZE/2)];
    CGPoint p1 = CGPointMake(Simble_SIZE/4+10, Simble_SIZE/2+10);
    [path addLineToPoint:p1];
    
    
    CGPoint p2 = CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4);
    [path addLineToPoint:p2];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.lineWidth = 5;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
    
    [self addSubview:_logoView];
}

- (void)drawWarning
{
    [_logoView removeFromSuperview];
    _logoView = [[UIView alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Simble_SIZE)/2, Simble_TOP, Simble_SIZE, Simble_SIZE)];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/2) radius:Simble_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    [path moveToPoint:CGPointMake(Simble_SIZE/2, Simble_SIZE/6)];
    CGPoint p1 = CGPointMake(Simble_SIZE/2, Simble_SIZE/6*3.8);
    [path addLineToPoint:p1];
    
    [path moveToPoint:CGPointMake(Simble_SIZE/2, Simble_SIZE/6*4.5)];
    [path addArcWithCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/6*4.5) radius:2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor orangeColor].CGColor;
    layer.lineWidth = 5;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
    
    [self addSubview:_logoView];
}

@end
