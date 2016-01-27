//
//  SingleImageViewController.m
//  Abletive
//
//  Created by Cali on 10/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "SingleImageViewController.h"
#import "AppColor.h"
#import "UIImageView+WebCache.h"
#import "MozTopAlertView.h"

@interface SingleImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;

@end

@implementation SingleImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [AppColor mainBlack];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (!self.displayImage) {
        [self.displayImageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL] placeholderImage:[UIImage imageNamed:@"Abletive LOGO Light Transparent.png"]];
    } else {
        self.displayImageView.image = self.displayImage;
    }
    self.displayImageView.backgroundColor = [AppColor transparent];
    UILongPressGestureRecognizer *longPresser = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage)];
    [self.displayImageView addGestureRecognizer:longPresser];
    self.displayImageView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveImage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"操作提示" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self save];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)save {
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImageWriteToSavedPhotosAlbum(self.displayImageView.image, nil, nil, nil);
        if (self.displayImageView.image) {
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"保存成功" parentView:self.view];
        }
    }else{
        if (self.displayImageView.image) {
            [MozTopAlertView showWithType:MozAlertTypeError text:@"没有用户权限,保存失败" parentView:self.view];
        }
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return @[[UIPreviewAction actionWithTitle:@"保存到相册" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImageWriteToSavedPhotosAlbum(self.displayImageView.image, nil, nil, nil);
            if (self.displayImageView.image) {
                [self.delegate imageSaved:YES];
            }
        }else{
            if (self.displayImageView.image) {
                [self.delegate imageSaved:NO];
            }
        }
             }],
             [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                 
             }]];
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
