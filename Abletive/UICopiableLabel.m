//
//  UICopiableLabel.m
//  Abletive
//
//  Created by Cali on 10/5/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UICopiableLabel.h"

@implementation UICopiableLabel

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

-(void)copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

-(void)attachTapHandler {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopy:)];
    [self addGestureRecognizer:touch];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self attachTapHandler];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self attachTapHandler];
}

-(void)handleCopy:(UIGestureRecognizer*) recognizer {
    [self becomeFirstResponder];
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil)
                                                      action:@selector(copy:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
}

@end
