//
//  ProfileAvatarUploadViewController.m
//  Abletive
//
//  Created by Cali on 10/20/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileAvatarUploadViewController.h"
#import "SXWaveView.h"
#import "TAOverlay.h"
#import "STPopup.h"
#import "AppColor.h"
#import "User.h"
#import "UIImageView+WebCache.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SIDES SCREEN_WIDTH/3.5
#define MARGIN SCREEN_WIDTH/28

@interface ProfileAvatarUploadViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *photoLibraryButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property(nonatomic,strong) SXWaveView *animateView;

@end

@implementation ProfileAvatarUploadViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 300);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 300);
    self.title = NSLocalizedString(@"上传头像", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cameraButton.hidden = YES;
    self.view.backgroundColor = [AppColor mainBlack];
    
    [self setUpButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpButtons {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.cameraButton.hidden = NO;
    }
}

- (void)imageAction:(NSUInteger)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Image Picker Delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [TAOverlay showOverlayWithLogoAndLabel:@"正在上传中..."];
    
    [User updateCurrentUserAvatar:imageData andBlock:^(BOOL success, NSString * _Nonnull message, NSString * _Nullable avatarURL) {
        [TAOverlay hideOverlay];
        if (success) {
            [[NSUserDefaults standardUserDefaults]setObject:avatarURL forKey:@"user_avatar_path"];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
            [userInfo setObject:@{@"avatar":avatarURL,@"gender":userInfo[@"public_info"][@"gender"],@"display_name":userInfo[@"public_info"][@"display_name"],@"url":userInfo[@"public_info"][@"url"],@"description":userInfo[@"public_info"][@"description"]} forKey:@"public_info"];
            [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user"];
            
            self.photoLibraryButton.hidden = YES;
            self.cameraButton.hidden = YES;
            
            SXWaveView *animateView = [[SXWaveView alloc]initWithFrame:CGRectMake(0, 0, SIDES, SIDES)];
            animateView.center = self.view.center;
            [self.view addSubview:animateView];
            self.animateView = animateView;
            [self.animateView setPrecent:100 description:@"上传成功" textColor:[AppColor mainBlack] bgColor:[AppColor mainBlack] alpha:1 clips:NO];
            [self.animateView addAnimateWithType:0];
            
            [self.delegate avatarChanged:image];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
                [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:avatarURL]];
            });
        } else {
            [TAOverlay showOverlayWithErrorText:@"上传失败，请重试"];
        }
    }];
    
}

- (IBAction)photoLibraryDidClick:(id)sender {
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self imageAction:sourceType];
}

- (IBAction)cameraDidClick:(id)sender {
    NSUInteger sourceType = UIImagePickerControllerSourceTypeCamera;
    [self imageAction:sourceType];
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
