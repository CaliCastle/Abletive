//
//  PICoachMark.m
//  NewPiki
//
//  Created by Pham Quy on 2/2/15.
//  Copyright (c) 2015 Pikicast Inc. All rights reserved.
//

#import "PIImageCoachmark.h"

@interface PIImageCoachmark ()
{
    CGRect _maskRect;
    CGFloat _maskCornerRadius;
    CGRect _viewRect;
    UIImageView* _view;
    UIImage* _image;
}
@property (nonatomic) CGRect maskRect;

@property (nonatomic) CGFloat maskCornerRadius;

@property (nonatomic) NSMutableArray* maskRects;
@property (nonatomic) NSMutableArray* cornerRadius;
@end

@implementation PIImageCoachmark
@synthesize maskRect=_maskRect;
@synthesize maskCornerRadius =_maskCornerRadius;
@synthesize view=_view;
@synthesize viewRect=_viewRect;
@synthesize maskRects=_maskRects;
@synthesize cornerRadius=_cornerRadius;

/*
 @{
     @"viewRect": @"{{0,0},{45,45}}",
     @"maskRect" : @"{{0,0},{45,45}}",
     @"cuttingCornerRadius" : @(10.),
     @"imageName" : @"01 coachmark_home.gif",
     @"animated" : @(NO)
 }
*/
- (instancetype) initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        
        if ([dictionary objectForKey:@"maskRect"]) {
            _maskRect = CGRectFromString([dictionary objectForKey:@"maskRect"]);
            _maskCornerRadius = [[dictionary objectForKey:@"maskRectCornerRadius"] floatValue];
            _maskRects = [@[[NSValue valueWithCGRect: _maskRect]] mutableCopy];
            _cornerRadius = [@[@(_maskCornerRadius)] mutableCopy];
        }else if ([dictionary objectForKey:@"maskRects"]){
            NSArray* mRects = [dictionary objectForKey:@"maskRects"];
            _maskRects = [@[] mutableCopy];
            _cornerRadius = [@[] mutableCopy];
            
            for (NSDictionary* mDict in mRects) {
                [_maskRects addObject:[NSValue valueWithCGRect:CGRectFromString(mDict[@"rect"])]];
                [_cornerRadius addObject:@([mDict[@"cornerRadius"] floatValue])];
            }
        }
            
        
        
        
        _viewRect = CGRectFromString([dictionary objectForKey:@"viewRect"]);
        NSString* imageName =  [dictionary objectForKey:@"imageName"];
        NSString* imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
        UIImage *progressImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        _image = progressImage;
        _view = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _duration = [dictionary objectForKey:@"duration"] ?  [[dictionary objectForKey:@"duration"] floatValue] : 1;
        _repeatCount = [dictionary objectForKey:@"repeat"] ?  [[dictionary objectForKey:@"repeat"] floatValue] : 1;
        
        
        
    }
    return  self;
}

- (NSArray*) maskPaths
{
    NSMutableArray* paths = [NSMutableArray array];
    
    for (int i = 0; i < _maskRects.count; i++) {
        CGRect maskRect = [(NSValue*)_maskRects[i] CGRectValue];
        CGFloat maskRad = [(NSNumber*)_cornerRadius[i] floatValue];
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:maskRect
                                                        cornerRadius:maskRad];
        [paths addObject:path];
    }
    
    return [NSArray arrayWithArray:paths];
}

- (void) start
{
    if (_image.images) {
        _view.animationImages = _image.images;
        _view.image = nil;
        
    }else{
        _view.animationImages = nil;
        _view.image =_image;
    }
    
    _view.animationDuration = _duration;
    _view.animationRepeatCount = _repeatCount;
    [_view startAnimating];
    
    [self performSelector:@selector(stop) withObject:nil afterDelay:_duration * _repeatCount];
}
- (void) stop
{
    [_view stopAnimating];
    _view.image = _image.images ? [_image.images lastObject] : _image;
    _view.animationImages = nil;
}
@end
