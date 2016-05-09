//
//  CheckInViewController.m
//  Abletive
//
//  Created by Cali on 10/12/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CheckInViewController.h"
#import "SOZOChromoplast.h"
#import "UIImageView+WebCache.h"
#import "ZMaterialButton.h"
#import "Personal Page/PersonalPageTableViewController.h"
#import "TAOverlay.h"
#import "AppColor.h"
#import "STPopup.h"
#import "Abletive-Swift.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define CHECKIN_BUTTON_SIZE 80

#define AVATAR_USER_SIZE ScreenWidth/5

@interface CheckInViewController () <ZMaterialButtonDelegate>

@property (nonatomic,strong) SOZOChromoplast *chromoplast;

@property (nonatomic,assign) BOOL isLightTheme;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *checkInTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkedInImageView;
@property (weak, nonatomic) IBOutlet UIButton *remindButton;

@property (nonatomic,strong) ZMaterialButton *materialButton;

@property (nonatomic,strong) NSMutableArray *checkedInUserList;

@end

@implementation CheckInViewController

- (SOZOChromoplast *)chromoplast {
    if (!_chromoplast) {
        _chromoplast = [[SOZOChromoplast alloc]initWithImage:[UIImage imageNamed:@"default-avatar"]];
    }
    return _chromoplast;
}

- (NSMutableArray *)checkedInUserList {
    if (!_checkedInUserList) {
        _checkedInUserList = [NSMutableArray array];
    }
    return _checkedInUserList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"每日签到", nil);
    [self.remindButton setTitle:NSLocalizedString(@"签到提醒", nil) forState:UIControlStateNormal];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"]]  placeholderImage:[UIImage imageNamed:@"default-avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            self.avatarImageView.image = image;
            self.chromoplast = [[SOZOChromoplast alloc]initWithImage:image];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                [TAOverlay showOverlayWithErrorText:@"头像加载失败，请重新登录"];
            }];
        }
        
    }];
    
    [self.closeButton setBackgroundImage:[[UIImage imageNamed:@"btn-close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    if (![self hasCheckedIn]) {
        // Not checked yet
        self.checkedInImageView.hidden = YES;
        
        self.avatarImageView.layer.cornerRadius = 35;
        self.avatarImageView.layer.shadowColor = [AppColor darkSeparator].CGColor;
        self.avatarImageView.layer.shadowOpacity = 0.5f;
        self.avatarImageView.layer.masksToBounds = YES;
        
        self.view.backgroundColor = self.chromoplast.dominantColor;
        self.remindButton.tintColor = self.chromoplast.firstHighlight;
        
        self.closeButton.tintColor = self.chromoplast.firstHighlight;
        self.closeButton.backgroundColor = [AppColor transparent];
        
        self.checkInTitleLabel.textColor = self.chromoplast.firstHighlight;
        self.checkInDescriptionLabel.textColor = self.chromoplast.secondHighlight;
        
        self.materialButton = [[ZMaterialButton alloc]initWithFrame:CGRectMake(ScreenWidth/2 - CHECKIN_BUTTON_SIZE/2, self.checkInDescriptionLabel.frame.origin.y + CHECKIN_BUTTON_SIZE + 10, CHECKIN_BUTTON_SIZE, CHECKIN_BUTTON_SIZE)];
        [self.materialButton setBackgroundColor:self.chromoplast.firstHighlight];
        [self.materialButton setBackgroundImage:[[UIImage imageNamed:@"checkin-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.materialButton setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
        [self.materialButton setEndAnimationPoint:CGPointMake(ScreenWidth/2 - CHECKIN_BUTTON_SIZE/2, self.materialButton.frame.origin.y + CHECKIN_BUTTON_SIZE)];
        self.materialButton.tintColor = self.chromoplast.dominantColor;
        [self.materialButton setTitleColor:self.chromoplast.dominantColor forState:UIControlStateNormal];
        [self.materialButton setChangeToImage:[UIImage new]];
        self.materialButton.expandBy = 150;
        self.materialButton.originalParentViewColor = self.chromoplast.dominantColor;
        self.materialButton.delegate = self;
        
        [self.view addSubview:self.materialButton];
        
        if ([[UIColor whiteColor] sozo_isCompatibleWithColor:[self.chromoplast dominantColor]]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
        
    } else {
        // Has already checked in
        self.checkInTitleLabel.text = @"今天已签到";
        self.checkInDescriptionLabel.text = @"";
        
        self.view.backgroundColor = self.chromoplast.firstHighlight;
        self.remindButton.tintColor = self.chromoplast.dominantColor;
        
        self.closeButton.tintColor = self.chromoplast.dominantColor;
        self.closeButton.imageView.tintColor = self.chromoplast.dominantColor;
        
        self.avatarImageView.layer.cornerRadius = 35;
        self.avatarImageView.layer.shadowColor = [AppColor darkSeparator].CGColor;
        self.avatarImageView.layer.shadowOpacity = 0.5f;
        self.avatarImageView.layer.masksToBounds = YES;
        
        self.checkedInImageView.image = [[UIImage imageNamed:@"checkedin-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.checkedInImageView.alpha = 0;
        self.checkedInImageView.hidden = NO;
        self.checkedInImageView.tintColor = self.chromoplast.dominantColor;
        self.checkInTitleLabel.textColor = self.chromoplast.dominantColor;
        self.checkInDescriptionLabel.textColor = self.chromoplast.dominantColor;
        
        [self sendCheckInRequest:YES];
        
        if ([[UIColor whiteColor] sozo_isCompatibleWithColor:[self.chromoplast firstHighlight]]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
    }
    
    [self loadAnimation];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [self loadAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)loadAnimation {
    CGRect startFrame = self.avatarImageView.frame;
    CGRect endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y - 100, startFrame.size.width, startFrame.size.height);
    self.avatarImageView.frame = startFrame;
    self.avatarImageView.alpha = 0.2;
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.avatarImageView.frame = endFrame;
        self.avatarImageView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    startFrame = self.checkInDescriptionLabel.frame;
    endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y + 80, startFrame.size.width, startFrame.size.height);
    self.checkInDescriptionLabel.frame = startFrame;
    self.checkInDescriptionLabel.alpha = 0;
    [UIView animateWithDuration:0.6 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.checkInDescriptionLabel.frame = endFrame;
        self.checkInDescriptionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) hasCheckedIn {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *checkedDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"daily_checkin"]?[[NSUserDefaults standardUserDefaults] stringForKey:@"daily_checkin"]:@"";
    return [checkedDate isEqualToString:[dateFormatter stringFromDate:[NSDate date]]];
}

- (void) ZMaterialButtonDidExpandButton:(ZMaterialButton *)button withSuccces:(BOOL)success{
    self.checkInDescriptionLabel.text = @"";
    self.materialButton.hidden = YES;
    self.materialButton.userInteractionEnabled = NO;
    
    [self sendCheckInRequest:NO];
}

- (void)sendCheckInRequest:(BOOL)checked {
    [TAOverlay showOverlayWithLabel:@"请稍等..." Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeText | TAOverlayOptionOverlayTypeActivityDefault | TAOverlayOptionOverlayDismissTap];
    [User dailyCheckIn:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] andBlock:^(NSDictionary *JSON, NSError *error) {
        [TAOverlay hideOverlay];
        if (!error) {
            self.materialButton.enabled = NO;
            self.checkedInImageView.image = [[UIImage imageNamed:@"checkedin-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.checkedInImageView.alpha = 0;
            self.checkedInImageView.hidden = NO;
            self.checkedInImageView.tintColor = self.chromoplast.dominantColor;
            self.remindButton.tintColor = self.chromoplast.dominantColor;
            
            self.closeButton.tintColor = self.chromoplast.dominantColor;
            self.closeButton.imageView.tintColor = self.chromoplast.dominantColor;
            
            NSUInteger userIndex = 0;
            CGFloat xOffset = 10;
            CGFloat yOffset = self.checkedInImageView.frame.origin.y + self.checkedInImageView.frame.size.height + 50;
            
            UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yOffset, ScreenWidth, AVATAR_USER_SIZE)];
            scrollView.backgroundColor = [AppColor transparent];
            scrollView.showsHorizontalScrollIndicator = NO;
            
            for (NSDictionary *checkedUser in JSON[@"checkin_list"]) {
                UIView *userView = [[UIView alloc]initWithFrame:CGRectMake(userIndex * AVATAR_USER_SIZE, 0, AVATAR_USER_SIZE, AVATAR_USER_SIZE)];
                userView.backgroundColor = [AppColor transparent];
                
                UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOffset/2, 0, AVATAR_USER_SIZE - xOffset, AVATAR_USER_SIZE - xOffset)];
                
                User *currentUser = [User userWithAttributes:checkedUser];
                [userImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.avatarPath] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
                
                userImageView.userInteractionEnabled = YES;
                userImageView.layer.cornerRadius = (AVATAR_USER_SIZE - xOffset)/2;
                userImageView.layer.masksToBounds = YES;
                userImageView.tag = userIndex;
                
                UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userAvatarTapped:)];
                [userImageView addGestureRecognizer:tapper];
                
                [userView addSubview:userImageView];
                [scrollView addSubview:userView];
                
                [self.checkedInUserList addObject:currentUser];
                userIndex++;
            }
            scrollView.contentSize = CGSizeMake(userIndex * AVATAR_USER_SIZE, AVATAR_USER_SIZE);
            [self.view addSubview:scrollView];
            
            UILabel *rankLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yOffset + AVATAR_USER_SIZE + 10, ScreenWidth, 25)];
            rankLabel.textColor = self.chromoplast.dominantColor;
            rankLabel.text = NSLocalizedString(@"签到排行榜", nil);
            rankLabel.textAlignment = NSTextAlignmentCenter;
            rankLabel.font = [UIFont systemFontOfSize:18];
            [self.view addSubview:rankLabel];
            
            [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.checkInTitleLabel.textColor = self.chromoplast.dominantColor;
                self.checkInDescriptionLabel.textColor = self.chromoplast.dominantColor;
                self.checkInTitleLabel.text = NSLocalizedString(@"今天已签到", nil);
                self.checkInDescriptionLabel.text = JSON[@"msg"];
                self.checkedInImageView.alpha = 1;
            } completion:nil];
            
            if (!checked) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"YYYYMMdd"];
                [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"daily_checkin"];
            }
        } else {
            [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                [TAOverlay showOverlayWithError];
            }];
        }
    }];
}

- (void)userAvatarTapped:(UITapGestureRecognizer *)sender {
    User *currentUser = self.checkedInUserList[sender.view.tag];

    PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPage.currentUser = currentUser;

    [self.navigationController pushViewController:personalPage animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)remindButtonPressed:(id)sender {
    STPopupController *popup = [[STPopupController alloc]initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CheckInSettings"]];
    popup.cornerRadius = 12;
    popup.backgroundView = [[UIVisualEffectView alloc]initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    
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
