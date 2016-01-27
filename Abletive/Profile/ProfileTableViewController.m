//
//  ProfileTableViewController.m
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "TAOverlay.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "AppColor.h"
#import "STPopup.h"
#import "ProfileGenderTableViewController.h"
#import "ProfileStandardInputViewController.h"
#import "ProfileComplexInputViewController.h"
#import "ProfilePasswordChangeViewController.h"
#import "ProfileAvatarUploadViewController.h"
#import "UserProfile.h"
#import "MozTopAlertView.h"
#import "HHAlertView.h"

@interface ProfileTableViewController () <ProfileGenderDelegate,ProfileStandardInputDelegate,ProfileComplexInputDelegate,ProfileAvatarUploadDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinaWeiboLabel;
@property (weak, nonatomic) IBOutlet UILabel *qqLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic,strong) NSDictionary *profile;

@property (nonatomic,strong) NSIndexPath *currentSelectedIndexPath;

@property (nonatomic,assign) BOOL edited;

@end

@implementation ProfileTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [AppColor secondaryBlack];
    self.saveButton.layer.cornerRadius = 8;
    self.logoutButton.layer.cornerRadius = 8;
    self.saveButton.layer.masksToBounds = YES;
    self.logoutButton.layer.masksToBounds = YES;
    
    self.descriptionTextView.textColor = [AppColor lightTranslucent];
    self.descriptionTextView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(descriptionTextDidTap)];
    [self.descriptionTextView addGestureRecognizer:tapper];
    
    if (![[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"public_info"]) {
        // Resend request
        [TAOverlay showOverlayWithLabel:@"获取信息中..." Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlayTypeActivityBlur];
        [User getCurrentUserProfileInBlock:^(NSDictionary *profile, NSError *error) {
            [TAOverlay hideOverlay];
            if (!error) {
                self.profile = [NSDictionary dictionaryWithDictionary:profile];
                [self loadData];
            } else {
                [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }];
    } else {
        self.profile = @{@"public":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"public_info"],@"social":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"social_info"],@"private":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"private_info"]};
        [self loadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.profile[@"public"][@"avatar"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/5;
    self.avatarImageView.layer.masksToBounds = YES;
    self.genderLabel.text = [self.profile[@"public"][@"gender"] isEqualToString:@"male"] ? NSLocalizedString(@"男", nil) : [self.profile[@"public"][@"gender"] isEqualToString:@"female"] ? NSLocalizedString(@"女",nil) : NSLocalizedString(@"保密",nil);
    self.nicknameLabel.text = self.profile[@"public"][@"display_name"];
    self.urlLabel.text = self.profile[@"public"][@"url"];
    self.descriptionTextView.text = self.profile[@"public"][@"description"];
    self.sinaWeiboLabel.text = self.profile[@"social"][@"weibo"];
    self.qqLabel.text = self.profile[@"social"][@"qq"];
    self.userLoginLabel.text = self.profile[@"private"][@"login"];
    self.emailLabel.text = self.profile[@"private"][@"email"];
    
    self.genderLabel.textColor = [AppColor lightTranslucent];
    self.nicknameLabel.textColor = [AppColor lightTranslucent];
    self.urlLabel.textColor = [AppColor lightTranslucent];
    self.sinaWeiboLabel.textColor = [AppColor lightTranslucent];
    self.qqLabel.textColor = [AppColor lightTranslucent];
    self.userLoginLabel.textColor = [AppColor lightTranslucent];
    self.emailLabel.textColor = [AppColor lightTranslucent];
}

- (IBAction)cancelDidClick:(id)sender {
    if (self.edited) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定取消吗?" message:@"所有更改将不会保存" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)saveBarButtonDidClick:(id)sender {
    [self saveDidClick:sender];
}

- (IBAction)passwordChangeDidClick:(id)sender {
    ProfilePasswordChangeViewController *passwordChanger = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePasswordChange"];
    STPopupController *popup = [[STPopupController alloc]initWithRootViewController:passwordChanger];
    popup.style = STPopupStyleFormSheet;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [popup presentInViewController:self];
}

- (IBAction)saveDidClick:(id)sender {
    if (!self.edited) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    NSString *gender = [self.genderLabel.text isEqualToString:@"男"] ? @"male" : [self.genderLabel.text isEqualToString:@"女"] ? @"female" : @"other";
    NSDictionary *attributes = @{@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"],@"sina_weibo":self.sinaWeiboLabel.text,@"qq":self.qqLabel.text,@"display_name":self.nicknameLabel.text,@"url":self.urlLabel.text,@"description":self.descriptionTextView.text,@"gender":gender,@"email_address":self.emailLabel.text};
    
    [TAOverlay showOverlayWithLogoAndLabel:@"正在保存中..."];
    [User updateCurrentUserProfileWithAttributes:attributes andBlock:^(BOOL success, NSString *msg) {
        [TAOverlay hideOverlay];
        if (success) {
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:msg parentView:self.navigationController.navigationBar];
            self.saveButton.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
                    [userInfo setObject:@{@"avatar":userInfo[@"public_info"][@"avatar"],@"gender":gender,@"display_name":attributes[@"display_name"],@"url":attributes[@"url"],@"description":attributes[@"description"]} forKey:@"public_info"];
                    [userInfo setObject:@{@"weibo":attributes[@"sina_weibo"],@"qq":attributes[@"qq"]} forKey:@"social_info"];
                    [userInfo setObject:@{@"login":userInfo[@"private_info"][@"login"],@"email":attributes[@"email_address"]} forKey:@"private_info"];
                    [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:@"user"];
                    [self.delegate updateHeaderData];
                }];
            });
        } else {
            [MozTopAlertView showWithType:MozAlertTypeError text:msg parentView:self.navigationController.navigationBar];
        }
    }];
}

- (IBAction)logoutDidClick:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定要注销吗?" message:@"注销后无法享用会员功能" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate userDidClickLogout];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Delegate methods

- (void)genderChanged:(UserGenderType)gender {
    self.edited = YES;
    switch (gender) {
        case UserGenderMale:
            self.genderLabel.text = @"男";
            break;
        case UserGenderFemale:
            self.genderLabel.text = @"女";
            break;
        default:
            self.genderLabel.text = @"保密";
            break;
    }
}

- (void)textChanged:(NSString *)text {
    self.edited = YES;
    switch (self.currentSelectedIndexPath.section) {
        case 0:
        {
            switch (self.currentSelectedIndexPath.row) {
                case 2:
                    self.nicknameLabel.text = text;
                    break;
                case 3:
                    self.urlLabel.text = text;
                    break;
                case 4:
                    self.descriptionTextView.text = text;
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (self.currentSelectedIndexPath.row) {
                case 0:
                    self.sinaWeiboLabel.text = text;
                    break;
                default:
                    self.qqLabel.text = text;
                    break;
            }
            break;
        }
        case 2:
        {
            if (self.currentSelectedIndexPath.row == 1) {
                self.emailLabel.text = text;
                return;
            }
        }
    }
}

- (void)avatarChanged:(UIImage *)avatar {
    self.avatarImageView.image = avatar;
}

#pragma mark Table setup

- (UIView *)setHeaderForSectionWithTitle:(NSString *)title {
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown || orientation == UIInterfaceOrientationPortrait) {
        headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    }
    else {
        headerLabel.frame = CGRectMake(30.0, -10.0, 300.0, 44.0);
    }
    
    headerLabel.text = NSLocalizedString(title, nil);
    [customView addSubview:headerLabel];
    
    return customView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self setHeaderForSectionWithTitle:@"公开信息"];
        case 1:
            return [self setHeaderForSectionWithTitle:@"社交信息"];
        case 2:
            return [self setHeaderForSectionWithTitle:@"私人信息"];
        default:
            break;
    }
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self setHeaderForSectionWithTitle:@"他人可在您的个人主页中查看到以上信息"];
        case 2:
            return [self setHeaderForSectionWithTitle:@"只有您自己可见"];
        default:
            break;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 4) {
        return 0;
    }
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return 5;
    }
    return 45;
}

#pragma mark - Table view action

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelectedIndexPath = indexPath;
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProfileAvatarUploadViewController *avatarUploader = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileAvatarUpload"];
                        avatarUploader.delegate = self;
                        STPopupController *popup = [[STPopupController alloc]initWithRootViewController:avatarUploader];
                        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                        popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                        popup.cornerRadius = 8;
                        
                        popup.style = STPopupTransitionStyleSlideVertical;
                        [popup presentInViewController:self];
                    });
                    return;
                }
                case 1:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProfileGenderTableViewController *genderTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileGender"];
                        genderTVC.delegate = self;
                        genderTVC.gender = [self.genderLabel.text isEqualToString:@"男"] ? UserGenderMale : [self.genderLabel.text isEqualToString:@"女"] ? UserGenderFemale : UserGenderOther;
                        STPopupController *popup = [[STPopupController alloc]initWithRootViewController:genderTVC];
                        popup.style = STPopupStyleBottomSheet;
                        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                        popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                        popup.cornerRadius = 8;
                        [popup presentInViewController:self];
                    });
                    return;
                }
                case 2:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProfileStandardInputViewController *standardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStandardInput"];
                        standardInputVC.delegate = self;
                        standardInputVC.inputLimit = 45;
                        standardInputVC.title = @"更改昵称";
                        standardInputVC.defaultText = self.nicknameLabel.text;
                        
                        STPopupController *popup = [[STPopupController alloc]initWithRootViewController:standardInputVC];
                        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                        popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                        popup.cornerRadius = 8;
                        popup.style = STPopupTransitionStyleSlideVertical;
                        [popup presentInViewController:self];
                    });
                    return;
                }
                case 3:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProfileStandardInputViewController *standardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStandardInput"];
                        standardInputVC.delegate = self;
                        standardInputVC.inputLimit = 100;
                        standardInputVC.title = @"更改个人站点";
                        standardInputVC.defaultText = self.urlLabel.text;
                        
                        STPopupController *popup = [[STPopupController alloc]initWithRootViewController:standardInputVC];
                        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                        popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                        popup.cornerRadius = 8;
                        popup.style = STPopupTransitionStyleSlideVertical;
                        [popup presentInViewController:self];
                    });
                    return;
                }
                case 4:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self descriptionTextDidTap];
                    });
                    return;
                }
            }
        case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ProfileStandardInputViewController *standardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStandardInput"];
                            standardInputVC.delegate = self;
                            standardInputVC.inputLimit = 30;
                            standardInputVC.title = @"更改新浪微博";
                            standardInputVC.defaultText = self.sinaWeiboLabel.text;
                            
                            STPopupController *popup = [[STPopupController alloc]initWithRootViewController:standardInputVC];
                            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                            popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                            popup.cornerRadius = 8;
                            popup.style = STPopupTransitionStyleSlideVertical;
                            [popup presentInViewController:self];
                        });
                        return;
                    }
                    default:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ProfileStandardInputViewController *standardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStandardInput"];
                            standardInputVC.delegate = self;
                            standardInputVC.inputLimit = 12;
                            standardInputVC.title = @"更改QQ";
                            standardInputVC.defaultText = self.qqLabel.text;
                            standardInputVC.isNumeric = YES;
                            
                            STPopupController *popup = [[STPopupController alloc]initWithRootViewController:standardInputVC];
                            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                            popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                            popup.cornerRadius = 8;
                            popup.style = STPopupTransitionStyleSlideVertical;
                            [popup presentInViewController:self];
                        });
                        return;
                    }
                }
            }
            case 2:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            STPopupController *popup = [[STPopupController alloc]initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileUserLogin"]];
                            popup.cornerRadius = 8;
                            [popup presentInViewController:self];
                        });
                        return;
                    }
                    default:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ProfileStandardInputViewController *standardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStandardInput"];
                            standardInputVC.delegate = self;
                            standardInputVC.inputLimit = 50;
                            standardInputVC.title = @"更改邮箱";
                            standardInputVC.defaultText = self.emailLabel.text;
                            standardInputVC.isEmail = YES;
                            
                            STPopupController *popup = [[STPopupController alloc]initWithRootViewController:standardInputVC];
                            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                            popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                            popup.cornerRadius = 8;
                            popup.style = STPopupTransitionStyleSlideVertical;
                            [popup presentInViewController:self];
                        });
                        return;
                    }
                }
            }
            case 3:
            {
                // Password Changer
                ProfilePasswordChangeViewController *passwordChanger = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePasswordChange"];
                STPopupController *popup = [[STPopupController alloc]initWithRootViewController:passwordChanger];
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                popup.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                popup.style = STPopupStyleFormSheet;
                popup.cornerRadius = 8;
                [popup presentInViewController:self];
                
                return;
            }
        }
        default:
            break;
    }
}

- (void)descriptionTextDidTap {
    self.currentSelectedIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    ProfileComplexInputViewController *complextInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileComplexInput"];
    complextInputVC.delegate = self;
    complextInputVC.title = @"更改个人介绍";
    complextInputVC.inputLimit = 150;
    complextInputVC.defaultText = self.descriptionTextView.text;
    
    STPopupController *popup = [[STPopupController alloc]initWithRootViewController:complextInputVC];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    popup.backgroundView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    popup.style = STPopupTransitionStyleFade;
    [popup presentInViewController:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
