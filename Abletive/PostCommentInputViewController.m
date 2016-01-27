//
//  PostCommentInputViewController.m
//  Abletive
//
//  Created by Cali on 11/11/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostCommentInputViewController.h"
#import "AppColor.h"
#import "STPopup.h"

@interface PostCommentInputViewController ()

@end

@implementation PostCommentInputViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 150);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 150);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"评论", nil);
    self.inputLimit = 200;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [AppColor mainBlack];
    self.inputField.text = self.defaultText;
    self.inputField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.defaultPlaceholder attributes:@{NSForegroundColorAttributeName:[AppColor lightTranslucent]}];
    self.inputField.placeholder = self.defaultPlaceholder;
    self.inputField.backgroundColor = [AppColor mainBlack];
    self.inputField.layer.masksToBounds = YES;
    self.inputField.layer.borderWidth = 1.f;
    self.inputField.layer.cornerRadius = 10.f;
    self.inputField.layer.borderColor = [AppColor transparent].CGColor;
    self.inputField.returnKeyType = UIReturnKeyDone;
    
    [self.inputField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inputDidEndOnExit:(UITextField *)sender {
    if (![sender.text isEqualToString:@""] || sender.text.length <= self.inputLimit) {
        [self.delegate inputEnded:sender.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
