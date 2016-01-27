//
//  LoginViewController.m
//  Abletive
//
//  Created by Cali on 6/28/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//
#import "LoginViewController.h"
#import "UIView+MJAlertView.h"
#import "AppColor.h"
#import "RegisterTableViewController.h"
#import "UIImage+Rounded.h"
#import "TAOverlay.h"
#import "AFNetworking.h"
#import "PasswordForgetViewController.h"
#import "PushNotification.h"
#import "User.h"

#import "CCDeviceDetecter.h"

@interface LoginViewController () <RegisterTableViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *attributes;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic,strong) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@end

static NSString * const appid = @"aaf98f894e2360b4014e250f080f02f0";
static NSString * const apptoken = @"76a8573a0ff08ae815f1f745de1bae76";

@implementation LoginViewController

#pragma mark - Instantiation

- (NSMutableDictionary *)attributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _attributes;
}

- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    }
    _blurEffectView.frame = self.view.frame;
    return _blurEffectView;
}

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([UIScreen mainScreen].bounds.size.height < 500){
        self.backgroundImage.image = [UIImage imageNamed:@"login-background.4s.jpg"];
    }
    
    // Add custom gesture to dismiss the view
    UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeDidClick:)];
    [swiper setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swiper];
    
    [[UILabel appearance]setTextColor:[UIColor whiteColor]];
    
    [self.loginButton setBackgroundImage:[UIImage roundedImageWithSize:self.loginButton.frame.size andBorderRadius:10 forBackgroundColor:[AppColor loginButtonColor]] forState:UIControlStateNormal];
}

#pragma mark - Input actions

- (IBAction)usernameDidEnd:(UITextField *)sender {
    [self.passwordField becomeFirstResponder];
}

- (IBAction)passwordDidBegin:(id)sender {
    [self blur];
}

- (IBAction)passwordDidEndEditing:(id)sender {
    [self unblur];
}

- (IBAction)passwordDidEnd:(UITextField *)sender {
    [self unblur];
    [self loginDidClick:nil];
}

- (IBAction)loginDidClick:(id)sender {
    [self.view endEditing:YES];
    if (!self.usernameField.text || [self.usernameField.text isEqualToString:@""]) {
        [self.usernameField becomeFirstResponder];
        return;
    }
    if (!self.passwordField.text || [self.passwordField.text isEqualToString:@""]) {
        [self.passwordField becomeFirstResponder];
        return;
    }
    
    self.attributes[@"username"] = self.usernameField.text;
    self.attributes[@"password"] = self.passwordField.text;
    
    [self loginValidate];
}

- (IBAction)registerDidClick:(id)sender {
    RegisterTableViewController *registerTVC = [[RegisterTableViewController alloc]initWithNibName:@"RegisterTableViewController" bundle:[NSBundle mainBundle]];
//    registerTVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    registerTVC.delegate = self;
    [self presentViewController:registerTVC animated:YES completion:nil];
}

- (IBAction)forgetDidClick:(id)sender {
    PasswordForgetViewController *pfVC = [[PasswordForgetViewController alloc]initWithNibName:@"PasswordForgetViewController" bundle:[NSBundle mainBundle]];
    pfVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:pfVC animated:YES completion:nil];
}

- (IBAction)closeDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showOverlayWithLogo:(NSString *)labelText {
    [TAOverlay showOverlayWithLabel:labelText ImageArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"logo-loading-01"],[UIImage imageNamed:@"logo-loading-02"],[UIImage imageNamed:@"logo-loading-03"],[UIImage imageNamed:@"logo-loading-04"], [UIImage imageNamed:@"logo-loading-05"], [UIImage imageNamed:@"logo-loading-06"], [UIImage imageNamed:@"logo-loading-07"], [UIImage imageNamed:@"logo-loading-08"], [UIImage imageNamed:@"logo-loading-09"], [UIImage imageNamed:@"logo-loading-10"], [UIImage imageNamed:@"logo-loading-11"], [UIImage imageNamed:@"logo-loading-12"], [UIImage imageNamed:@"logo-loading-13"], [UIImage imageNamed:@"logo-loading-14"], [UIImage imageNamed:@"logo-loading-15"], [UIImage imageNamed:@"logo-loading-16"], [UIImage imageNamed:@"logo-loading-17"], [UIImage imageNamed:@"logo-loading-18"], [UIImage imageNamed:@"logo-loading-19"], [UIImage imageNamed:@"logo-loading-20"], nil] Duration:1.2 Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlaySizeRoundedRect];
}

- (void)loginValidate {
    // Show loading process
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOverlayWithLogo:@"正在验证中...请稍等"];
    });
    self.loginButton.enabled = NO;
    // Send request to server's database
    [[AbletiveAPIClient sharedClient] POST:@"user/generate_auth_cookie/" parameters:self.attributes success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        // Request success
        [TAOverlay hideOverlay];
        self.loginButton.enabled = YES;
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            // Login success
            // Store values into user defaults
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"user_is_logged"];
            [[NSUserDefaults standardUserDefaults]setObject:JSON[@"cookie"] forKey:@"user_cookie"];
            // Store user dictionary into user defaults
            [[NSUserDefaults standardUserDefaults]setObject:JSON[@"user"] forKey:@"user"];
            
            /**
             *  Get user's membership info
             */
            [User getCurrentUserMembership:^(BOOL hasExpired) {
                if (!hasExpired) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsVIP"];
                } else {
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"IsVIP"]) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsVIP"];
                    }
                }
            }];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
                NSString *newToken = [[NSUserDefaults standardUserDefaults]stringForKey:@"deviceToken"];
                [PushNotification updateUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] withToken:newToken];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TAOverlay showOverlayWithLabel:@"登陆成功!" Options:TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlaySizeBar | TAOverlayOptionAutoHide];
            });
            
            // Synchronize defaults
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            if (IOS_VERSION_9_OR_ABOVE) {
                // Available only in iOS 9 or above
                // ==== IMPORTANT ====
                // Change the Shortcut Item Subtitle of "Me"
                UIApplication *application = [UIApplication sharedApplication];
                NSArray *shortcutItems = [application shortcutItems];
                UIMutableApplicationShortcutItem *oldItem = [shortcutItems lastObject];
                UIMutableApplicationShortcutItem *mutableItem = [oldItem mutableCopy];
                [mutableItem setLocalizedTitle:[NSString stringWithFormat:@"%@的主页",[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"displayname"]]];
                [mutableItem setLocalizedSubtitle:@""];
                
                id updatedShortcutItems = [shortcutItems mutableCopy];
                [updatedShortcutItems replaceObjectAtIndex:[shortcutItems count]-1 withObject: mutableItem];
                [application setShortcutItems: updatedShortcutItems];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"User_Login" object:nil];
            // Dismiss the current View Controller
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self youShouldDismiss];
            });
        }
        else {
            // Login failed
            [UIView addMJNotifierWithText:@"账号或密码不正确" andStyle:MJAlertViewError dismissAutomatically:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // Request failed
        [TAOverlay hideOverlay];
        self.loginButton.enabled = YES;
        [UIView addMJNotifierWithText:@"网络请求失败,请检查网络设置" andStyle:MJAlertViewError dismissAutomatically:NO];
    }];
}

#pragma mark - Blur Effect

- (void)blur {
    self.blurEffectView.alpha = 0;
    [self.view insertSubview:self.blurEffectView aboveSubview:self.backgroundImage];
    [UIView animateWithDuration:0.4 animations:^{
        self.blurEffectView.alpha = 1;
    }];
}

- (void)unblur {
    [UIView animateWithDuration:0.4 animations:^{
        self.blurEffectView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.blurEffectView removeFromSuperview];
    }];
}

#pragma mark - Register Table View Delegate

- (void)youShouldDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.view endEditing:YES];
}

@end
