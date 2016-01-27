//
//  RegisterTableViewController.m
//  Abletive
//
//  Created by Cali on 6/20/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "RegisterTableViewCell.h"
#import "UIView+MJAlertView.h"
#import "UIImage+Rounded.h"
#import "AFNetworking.h"
#import "TAOverlay.h"
#import "PushNotification.h"
#import "AppColor.h"

#import "CCDeviceDetecter.h"

@interface RegisterTableViewController ()

@property (readwrite,nonatomic,strong) NSMutableDictionary *attributes;
@property (readwrite,nonatomic,assign) BOOL isPwdCorrect;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *registerButtonView;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (nonatomic,strong) UIVisualEffectView *blurEffectView;

@end

@implementation RegisterTableViewController

- (NSMutableDictionary *)attributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary dictionaryWithCapacity:5];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.registerButton setBackgroundImage:[UIImage roundedImageWithSize:self.registerButton.frame.size andBorderRadius:10 forBackgroundColor:[AppColor registerButtonColor]] forState:UIControlStateNormal];
    self.tableView.tableFooterView = self.registerButtonView;
    // Register the cell
    [self.tableView registerNib:[UINib nibWithNibName:@"RegisterTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RegisterInput"];
    // Initialize variable
    self.isPwdCorrect = NO;
    // Set the background
    self.backgroundImageView.image = [UIImage imageNamed:@"register-background.jpg"];
    self.tableView.backgroundView = self.backgroundImageView;
    // Close button
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 35, 35)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"btn-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    self.tableView.bounces = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegisterInput" forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            // Username field
            cell.icon.image = [UIImage imageNamed:@"account"];
            cell.inputField.placeholder = @"注册用户名";
            cell.inputField.keyboardType = UIKeyboardTypeASCIICapable;
            cell.inputField.returnKeyType = UIReturnKeyDone;
            [cell.inputField addTarget:self action:@selector(setUsername:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            break;
        case 1:
            // Nickname field
            cell.icon.image = [UIImage imageNamed:@"account"];
            cell.inputField.placeholder = @"显示的昵称";
            cell.inputField.returnKeyType = UIReturnKeyDone;
            [cell.inputField addTarget:self action:@selector(setNickname:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            break;
        case 2:
            // Password field
            cell.icon.image = [UIImage imageNamed:@"password"];
            cell.inputField.placeholder = @"注册密码";
            cell.inputField.secureTextEntry = YES;
            cell.inputField.returnKeyType = UIReturnKeyDone;
            [cell.inputField addTarget:self action:@selector(setPassword:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(blurBackground) forControlEvents:UIControlEventEditingDidBegin];
            [cell.inputField addTarget:self action:@selector(removeBlurBackground) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            break;
        case 3:
            // Repeat password
            cell.inputField.placeholder = @"再输入一次密码";
            cell.inputField.secureTextEntry = YES;
            [cell.inputField addTarget:self action:@selector(validatePassword:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(blurBackground) forControlEvents:UIControlEventEditingDidBegin];
            [cell.inputField addTarget:self action:@selector(removeBlurBackground) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            break;
        case 4:
            // Email field
            cell.icon.image = [UIImage imageNamed:@"email"];
            cell.inputField.placeholder = @"注册邮箱地址";
            cell.inputField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.inputField.returnKeyType = UIReturnKeyDone;
            [cell.inputField addTarget:self action:@selector(setEmail:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.inputField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            break;
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.view.bounds.size.height * 0.4;
}

- (void)showOverlayWithLogo:(NSString *)labelText {
    [TAOverlay showOverlayWithLabel:labelText ImageArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"logo-loading-01"],[UIImage imageNamed:@"logo-loading-02"],[UIImage imageNamed:@"logo-loading-03"],[UIImage imageNamed:@"logo-loading-04"], [UIImage imageNamed:@"logo-loading-05"], [UIImage imageNamed:@"logo-loading-06"], [UIImage imageNamed:@"logo-loading-07"], [UIImage imageNamed:@"logo-loading-08"], [UIImage imageNamed:@"logo-loading-09"], [UIImage imageNamed:@"logo-loading-10"], [UIImage imageNamed:@"logo-loading-11"], [UIImage imageNamed:@"logo-loading-12"], [UIImage imageNamed:@"logo-loading-13"], [UIImage imageNamed:@"logo-loading-14"], [UIImage imageNamed:@"logo-loading-15"], [UIImage imageNamed:@"logo-loading-16"], [UIImage imageNamed:@"logo-loading-17"], [UIImage imageNamed:@"logo-loading-18"], [UIImage imageNamed:@"logo-loading-19"], [UIImage imageNamed:@"logo-loading-20"], nil] Duration:1.2 Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlaySizeRoundedRect];
}

#pragma mark - Register validation

- (IBAction)registerValidate {
    [self.view endEditing:YES];
    // If any field is empty
    if (!self.attributes[@"username"] || !self.attributes[@"user_pass"] || !self.attributes[@"email"] || !self.attributes[@"display_name"]) {
        [UIView addMJNotifierWithText:NSLocalizedString(@"请填写有效信息", nil) andStyle:MJAlertViewError dismissAutomatically:YES];
        return;
    }
    // If email address is invalid
    if (![self.attributes[@"email"] containsString:@"@"] || ![self.attributes[@"email"] containsString:@"."]) {
        [UIView addMJNotifierWithText:NSLocalizedString(@"请认真填写邮箱地址", nil) andStyle:MJAlertViewError dismissAutomatically:YES];
        return;
    }
    // If passwords unpaired
    if (!self.isPwdCorrect) {
        [UIView addMJNotifierWithText:NSLocalizedString(@"密码不匹配", nil) andStyle:MJAlertViewError dismissAutomatically:YES];
        return;
    }
    // Show loading progress and send request to server's database
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOverlayWithLogo:NSLocalizedString(@"正在注册中...请稍等", nil)];
    });
    
    // Get nonce
    [[AbletiveAPIClient sharedClient] GET:@"get_nonce" parameters:@{@"controller":@"user",@"method":@"register"} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            [self.attributes setObject:JSON[@"nonce"] forKey:@"nonce"];
            // Send registration request
            [[AbletiveAPIClient sharedClient] GET:@"user/register" parameters:self.attributes success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
                [TAOverlay hideOverlay];
                // Request success
                if ([JSON[@"status"] isEqualToString:@"ok"]) {
                    // Registration success
                    self.registerButton.enabled = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [TAOverlay showOverlayWithLabel:NSLocalizedString(@"注册成功!请稍等", nil) Options:TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayShadow];
                    });

                    // Get other informations
                    [[AbletiveAPIClient sharedClient] GET:@"user/get_currentuserinfo" parameters:@{@"cookie":JSON[@"cookie"]} success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                        [TAOverlay hideOverlay];
                        // Store the user dictionary into user defaults
                        [[NSUserDefaults standardUserDefaults]setObject:responseObject[@"user"] forKey:@"user"];
                        // Dismiss the current register TVC
                        [self dismissViewControllerAnimated:YES completion:^{
                            // Then store the values into user defaults
                            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"user_is_logged"];
                            [[NSUserDefaults standardUserDefaults]setObject:JSON[@"cookie"] forKey:@"user_cookie"];
                            
                            if (IOS_VERSION_9_OR_ABOVE) {
                                // Available only in iOS 9 or above
                                // ==== IMPORTANT ====
                                // Change the Shortcut Item Subtitle of "Me"
                                UIApplication *application = [UIApplication sharedApplication];
                                NSArray *shortcutItems = [application shortcutItems];
                                UIMutableApplicationShortcutItem *oldItem = [shortcutItems lastObject];
                                UIMutableApplicationShortcutItem *mutableItem = [oldItem mutableCopy];
                                [mutableItem setLocalizedSubtitle:[NSString stringWithFormat:@"%@的主页",JSON[@"user"][@"displayname"]]];
                                
                                id updatedShortcutItems = [shortcutItems mutableCopy];
                                [updatedShortcutItems replaceObjectAtIndex:[shortcutItems count]-1 withObject: mutableItem];
                                [application setShortcutItems: updatedShortcutItems];
                            }
                            
                            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
                                NSString *newToken = [[NSUserDefaults standardUserDefaults]stringForKey:@"deviceToken"];
                                [PushNotification updateUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] withToken:newToken];
                            }
                            // Dismiss the login TVC
                            [self.delegate youShouldDismiss];
                        }];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [UIView addMJNotifierWithText:@"未知错误异常" andStyle:MJAlertViewWarning dismissAutomatically:YES];
                    }];
                }
                else {
                    // Registration failed
                    if ([JSON[@"error"] isEqualToString:@"Username already exists."]) {
                        [UIView addMJNotifierWithText:@"用户名已存在" andStyle:MJAlertViewError dismissAutomatically:NO];
                    }
                    else if ([JSON[@"error"] isEqualToString:@"Username is invalid."]) {
                        [UIView addMJNotifierWithText:@"用户名不规范,请勿使用中文等其他不合法字符" andStyle:MJAlertViewError dismissAutomatically:NO];
                    }
                    else if ([JSON[@"error"] isEqualToString:@"E-mail address is already in use."]) {
                        [UIView addMJNotifierWithText:@"邮箱已存在" andStyle:MJAlertViewError dismissAutomatically:NO];
                    }
                    else if ([JSON[@"error"] isEqualToString:@"E-mail address is invalid."]){
                        [UIView addMJNotifierWithText:@"邮箱地址出错" andStyle:MJAlertViewError dismissAutomatically:NO];
                    }
                    else {
                        [UIView addMJNotifierWithText:@"请求出错,请稍后再试" andStyle:MJAlertViewError dismissAutomatically:NO];
                        NSLog(@"Error:%@",JSON[@"error"]);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                // Request failed
                [TAOverlay hideOverlay];
                [UIView addMJNotifierWithText:@"服务器请求失败" andStyle:MJAlertViewError dismissAutomatically:YES];
            }];
        }
        else {
            [TAOverlay hideOverlay];
            [UIView addMJNotifierWithText:@"获取请求失败" andStyle:MJAlertViewError dismissAutomatically:YES];
            return;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [TAOverlay hideOverlay];
        [UIView addMJNotifierWithText:@"请求失败,请稍后再试" andStyle:MJAlertViewError dismissAutomatically:NO];
        return;
    }];
}

#pragma mark - Input actions

- (void)setUsername:(UITextField *)inputField {
    if ([inputField.text isEqualToString:@""]) {
        return;
    }
    [self.attributes setObject:inputField.text forKey:@"username"];
}

- (void)setPassword:(UITextField *)inputField {
    if ([inputField.text isEqualToString:@""]) {
        return;
    }
    [self.attributes setObject:inputField.text forKey:@"user_pass"];
}

- (void)setEmail:(UITextField *)inputField {
    if ([inputField.text isEqualToString:@""]) {
        return;
    }
    [self.attributes setObject:inputField.text forKey:@"email"];
}

- (void)setNickname:(UITextField *)inputField {
    if ([inputField.text isEqualToString:@""]) {
        return;
    }
    [self.attributes setObject:inputField.text forKey:@"display_name"];
}

- (void)validatePassword:(UITextField *)inputField {
    if ([inputField.text isEqualToString:self.attributes[@"user_pass"]]) {
        self.isPwdCorrect = YES;
    }
}

- (void)blurBackground {
    [self.view insertSubview:self.blurEffectView atIndex:1];
}

- (void)removeBlurBackground {
    [self.blurEffectView removeFromSuperview];
}

- (void)hideKeyboard {
    [self.view resignFirstResponder];
}

#pragma mark - Hide View Controller

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
