//
//  PasswordForgetViewController.m
//  Abletive
//
//  Created by Cali on 6/28/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PasswordForgetViewController.h"
#import "Networking Extension/AbletiveAPIClient.h"
#import "AFNetworking.h"
#import "TAOverlay.h"

@interface PasswordForgetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@end

@implementation PasswordForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UILabel appearance]setTextColor:[UIColor whiteColor]];
}
- (IBAction)usernameDidEndOnExit:(id)sender {
    [self retreiveDidClick:nil];
}

- (IBAction)retreiveDidClick:(id)sender {
    [self.view endEditing:YES];
    if (!self.usernameField.text || [self.usernameField.text isEqualToString:@""]) {
        [self.usernameField becomeFirstResponder];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [TAOverlay showOverlayWithLabel:@"正在发送邮件...请稍等" Options:TAOverlayOptionOverlayTypeActivityLeaf | TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlaySizeRoundedRect];
    });
    [[AbletiveAPIClient sharedClient]GET:@"user/retrieve_password" parameters:@{@"user_login":self.usernameField.text} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        [TAOverlay hideOverlay];
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            // Retreive succeeded
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TAOverlay showOverlayWithLabel:@"邮件发送成功!请查收邮件" Options:TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlaySizeBar];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TAOverlay hideOverlay];
                [self closeDidClick:nil];
            });
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TAOverlay showOverlayWithLabel:@"邮件发送失败!" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError];
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [TAOverlay hideOverlay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TAOverlay showOverlayWithLabel:@"请求失败!" Options:TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeError | TAOverlayOptionAutoHide];
        });
    }];
}

- (void)swipeLeft {
    [self closeDidClick:nil];
}

- (IBAction)closeDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.view endEditing:YES];
}

@end
