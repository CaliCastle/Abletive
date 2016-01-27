
//
//  SinglePostTableViewController.m
//  Abletive
//
//  Created by Cali on 7/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "KINWebBrowser/KINWebBrowserViewController.h"
#import "SortPostTableViewController.h"
#import "SinglePostTableViewController.h"
#import "SinglePostHeaderViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Rounded.h"
#import "NSString+FilterHTML.h"
#import "CommentTableViewCell.h"
#import "AuthorTableViewCell.h"
#import "AppColor.h"
#import "AppFont.h"
#import "AHKActionSheet.h"
#import "TAOverlay.h"
#import "User.h"
#import "MozTopAlertView.h"
#import "Personal Page/PersonalPageTableViewController.h"
#import "MLPhotoBrowserAssets.h"
#import "MLPhotoBrowserViewController.h"
#import "CBStoreHouseRefreshControl.h"
#import "PostDetail.h"
#import "STPopup.h"

#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

#import "SingleImageViewController.h"
#import "CCDeviceDetecter.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define INPUT_HEIGHT 70
#define AUTHOR_TABLE_CELL_HEIGHT 100


typedef NS_ENUM(NSUInteger,ShareType){
    ShareTypeSinaWeibo,
    ShareTypeQQZone,
    ShareTypeQQ,
    ShareTypeMoments,
    ShareTypeWechat,
    ShareTypeSMS,
    ShareTypeCopyURL,
    ShareTypeEmail,
    ShareTypeLocal
};

@interface SinglePostTableViewController () <SinglePostHeaderDelegate,AuthorCellDelegate,CommentCellDelegate,MLPhotoBrowserViewControllerDelegate,UIViewControllerPreviewingDelegate,PersonalPageDelegate,SingleImageDelegate>

@property (nonatomic,strong) SinglePostHeaderViewController *headerController;
@property (nonatomic,strong) IBOutlet UITextField *commentInput;
@property (nonatomic,strong) IBOutlet UIButton *sendButton;
@property (nonatomic,strong) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkLabel;

@property (nonatomic,assign) NSUInteger commentTo;

@property (nonatomic,strong) NSMutableArray *photos;

@property (nonatomic,strong) UIImage *thumbnail;

@property (nonatomic,strong) CBStoreHouseRefreshControl *headerRefreshControl;

// Keyboard related
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) BOOL isKeyboardOpen;

@end

static NSString * const authorCellReuse = @"Author_Cell";
static NSString * const commentCellReuse = @"Comment_Cell";

static NSString * const normalReplyPlaceholder = @"评论一下，说点什么吧...";
static NSString * const unloggedReplyPlaceholder = @"登录以后才能发表评论哦";

@implementation SinglePostTableViewController {
    UIImageView* _backgroundView;
    UIVisualEffectView* _blurEffectView;
    UIBlurEffect* _blurEffect;
    CGSize _keyboardSize;
    BOOL _submitting;
}

- (SinglePostHeaderViewController *)headerController {
    if (!_headerController) {
        _headerController = [[SinglePostHeaderViewController alloc]initWithNibName:@"SinglePostHeaderViewController" bundle:[NSBundle mainBundle]];
    }
    return _headerController;
}

- (UITextField *)commentInput {
    if (!_commentInput){
        _commentInput = [[UITextField alloc]init];
    }
    return _commentInput;
}

- (UIImage *)thumbnail {
    if (!_thumbnail) {
        _thumbnail = [UIImage new];
    }
    return _thumbnail;
}

#pragma mark View related methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isFromPeek) {
        [TAOverlay showOverlayWithLogo];
    }
    
    if (!self.isPage) {
        // Show the progress loading
        if (self.postSlug) {
            [PostDetail getPostDetailBySlug:self.postSlug andBlock:^(PostDetail *detailPost, NSError *error) {
                if (!error) {
                    if (!self.isFromPeek) {
                        [TAOverlay hideOverlay];
                    }
                    self.currentPost = detailPost;
                    
                    [self dataLoaded];
                    
                } else {
                    [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                        if (finished) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                }
            }];
        } else {
            [PostDetail postDetailByID:self.postID withCookie:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_cookie"] andBlock:^(PostDetail *detailPost, NSError *error) {
                if (!error) {
                    if (!self.isFromPeek) {
                        [TAOverlay hideOverlay];
                    }
                    self.currentPost = detailPost;
                    
                    [self dataLoaded];
                    
                } else {
                    [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                        if (finished) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                }
            }];
        }
        
    } else {
        // Show the progress loading
        [PostDetail pageDetailByID:self.postID andBlock:^(PostDetail *detailPage, NSError *error) {
            if (!error) {
                if (!self.isFromPeek) {
                    [TAOverlay hideOverlay];
                }
                self.currentPost = detailPage;
                
                [self dataLoaded];
                
            } else {
                [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                    if (finished) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AuthorTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:authorCellReuse];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:commentCellReuse];
    
}

- (void)dataLoaded {
    _submitting = NO;
    self.commentTo = 0;
    
    self.title = self.currentPost.title;
    
    self.currentPost.shortDescription = [NSString filterHTML:self.currentPost.shortDescription];
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionClicked)];
    // Set the custom blur background
    [self setUpBackgroundView];
    // Set the header view for post content
    [self setUpHeaderForPostContent];
    
    // Set transparent color
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.backgroundColor = [AppColor transparent];
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.08];
    // Set the bottom comment view's frame
    self.bottomView.frame = CGRectMake(0, ScreenHeight - INPUT_HEIGHT, ScreenWidth, INPUT_HEIGHT);
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        self.likeButton.enabled = NO;
        self.bookmarkButton.enabled = NO;
    }
    [self.likeButton setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.bookmarkButton setImage:[[UIImage imageNamed:@"add-to-bookmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.likeLabel.text = [NSString stringWithFormat:@"点赞 %lu 次",(unsigned long)self.currentPost.numberOfLikes];
    self.bookmarkLabel.text = [NSString stringWithFormat:@"收藏 %lu 人",(unsigned long)self.currentPost.numberOfBookmarks];
    
    self.likeButton.tintColor = [AppColor mainYellow];
    self.bookmarkButton.tintColor = [AppColor mainYellow];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]){
        self.sendButton.enabled = NO;
        self.commentInput.enabled = NO;
        self.commentInput.placeholder = unloggedReplyPlaceholder;
    }
    // Add it at top of the view layer
    [self.view addSubview:self.bottomView];
    
    self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[AppColor mainWhite] lineWidth:1.5 dropHeight:100 scale:0.75 horizontalRandomness:400 reverseLoadingAnimation:YES internalAnimationFactor:0.7];
    self.sendButton.enabled = NO;
    self.lastPoint = CGPointZero;
    [self registerForKeyboardNotifications];
    [self scrollViewDidScroll:self.tableView];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openVideoWithURL:(NSString *)url {
    UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];

    [self presentViewController:webBrowser animated:YES completion:^{
        [webBrowser.rootWebBrowser loadURLString:url];
    }];
}

- (void)openLinkWithURL:(NSString *)url {
    
    if ([url containsString:@"http://abletive.com/"]) {
        SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postSlug = url;
        
        [self.navigationController pushViewController:singlePostTVC animated:YES];
        
    } else {
        UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
        webBrowser.rootWebBrowser.showsURLInNavigationBar = YES;
        [self presentViewController:webBrowser animated:YES completion:^{
            [webBrowser.rootWebBrowser loadURLString:url];
        }];
    }
    
}

- (void)headerRefreshTriggered:(id)sender {
    [PostDetail postDetailByID:self.currentPost.postID withCookie:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_cookie"] andBlock:^(PostDetail *detailPost, NSError *error) {
        [self.headerRefreshControl finishingLoading];
        if (!error) {
            self.currentPost = detailPost;
            [self setUpHeaderForPostContent];
            [self.tableView reloadData];
        } else {
            [TAOverlay showOverlayWithError];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.headerRefreshControl scrollViewDidScroll];
    self.commentTo = 0;
    self.commentInput.placeholder = normalReplyPlaceholder;
    if ([self.commentInput isFirstResponder]) {
        [self.commentInput resignFirstResponder];
    }
    // Fixed positioning at bottom of the screen
    self.bottomView.frame = CGRectMake(0, self.tableView.contentOffset.y + ScreenHeight - INPUT_HEIGHT, ScreenWidth, INPUT_HEIGHT);
    [self.tableView bringSubviewToFront:self.bottomView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerRefreshControl scrollViewDidEndDragging];

}

- (void)resetKeyboardFrame {
    self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + _keyboardSize.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.bottomView.frame = CGRectMake(0, self.tableView.contentOffset.y + ScreenHeight - INPUT_HEIGHT, ScreenWidth, INPUT_HEIGHT);
    [self.tableView bringSubviewToFront:self.bottomView];
}

#pragma mark Setup

- (void)setUpBackgroundView {
    _backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenHeight, ScreenHeight)];
    _backgroundView.center = self.view.center;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [_backgroundView sd_setImageWithURL:[NSURL URLWithString:self.currentPost.thumbnail] placeholderImage:[UIImage imageNamed:@"login-background.jpg"]];
    
    _blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:_blurEffect];
    _blurEffectView.frame = _backgroundView.frame;
    
    [_backgroundView addSubview:_blurEffectView];
    [self.tableView setBackgroundView:_backgroundView];
}

- (void)setUpHeaderForPostContent {
    self.headerController.delegate = self;
    self.headerController.currentPost = self.currentPost;
    self.tableView.tableHeaderView = self.headerController.view;
    
    if (IOS_VERSION_9_OR_ABOVE) {
        for (UIImageView *imageView in self.headerController.imageViews) {
            [self registerForPreviewingWithDelegate:self sourceView:imageView];
        }
        for (UIImageView *videoView in self.headerController.videoViews) {
            [self registerForPreviewingWithDelegate:self sourceView:videoView];
        }
        for (UILabel *url in self.headerController.linkLabels) {
            [self registerForPreviewingWithDelegate:self sourceView:url];
        }
    }
}

#pragma mark Keyboard Related

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self adjustKeyboard:aNotification andOpen:YES];
    self.isKeyboardOpen = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self adjustKeyboard:aNotification andOpen:NO];
    self.isKeyboardOpen = NO;
}

- (void)adjustKeyboard:(NSNotification *)aNotification andOpen:(BOOL)shouldOpen {
    if (shouldOpen) {
        self.view.frame = CGRectMake(self.lastPoint.x, self.lastPoint.y, self.view.bounds.size.width, self.view.bounds.size.height);
        self.lastPoint = self.view.frame.origin;
    }
    
    NSDictionary *userInfo = aNotification.userInfo;
    NSTimeInterval animationDuration = 0;
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseIn;
    CGRect keyboardFrame = CGRectZero;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.isKeyboardOpen && shouldOpen) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + (keyboardFrame.size.height * (shouldOpen ? -1 : 1)), self.view.frame.size.width, self.view.frame.size.height);
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationDuration:animationDuration];
        
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + (keyboardFrame.size.height * (shouldOpen ? -1 : 1)), self.view.frame.size.width, self.view.frame.size.height);
        
        [UIView commitAnimations];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return INPUT_HEIGHT;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [AppColor transparent];
    return footerView;
}

- (IBAction)commentInputDidChange:(UITextField *)sender {
    NSString *trimmed = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.sendButton.enabled = !([sender.text isEqualToString:@""] || [trimmed isEqualToString:@""]);
}

/**
 * After the send button tapped
 */
- (IBAction)sendDidClick:(id)sender {
    if (_submitting) {
        return;
    }
    NSString *content = self.commentInput.text;
    if ([content isEqualToString:@""]) {
        [self.commentInput becomeFirstResponder];
        return;
    }
    _submitting = YES;
    [TAOverlay showOverlayWithLabel:NSLocalizedString(@"正在评论中...", nil) Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeProgress | TAOverlayOptionOverlayTypeActivityBlur];
    if ([self.commentInput isFirstResponder]) {
        [self.commentInput resignFirstResponder];
        [self resetKeyboardFrame];
    }
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"];
    [Comment submitCommentWithPostID:self.currentPost.postID andUserInfo:@{@"user_id":userInfo[@"id"],@"content":content,@"name":userInfo[@"displayname"],@"parent":[NSNumber numberWithInteger:self.commentTo],@"email":userInfo[@"email"]} inBlock:^(Comment *newComment, NSError *error) {
        [TAOverlay hideOverlay];
        _submitting = NO;
        if (!error) {
            self.currentPost.commentCount++;
            [self.currentPost.comments addObject:newComment];
            // Clear out the content
            self.commentInput.text = @"";
            self.commentInput.placeholder = normalReplyPlaceholder;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"评论成功" parentView:self.navigationController.navigationBar];
                [self.tableView reloadData];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MozTopAlertView showWithType:MozAlertTypeError text:@"评论失败，请重试" parentView:self.navigationController.navigationBar];
            });
        }
    }];
}

/**
 * After the send button of keyboard tapped
 */

- (IBAction)submitComment:(UITextField *)sender {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]){
        [self sendDidClick:nil];
    }
}

- (IBAction)likeButtonDidClick:(id)sender {
    [self addLike];
}

- (IBAction)addToBookmarkDidClick:(UIButton *)sender {
    [self addCollection];
}

#pragma mark - Action Sheet

- (void)actionClicked {
    if ([self.commentInput isFirstResponder]) {
        [self.commentInput resignFirstResponder];
        [self resetKeyboardFrame];
    }
    
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc]initWithTitle:nil];
    actionSheet.blurTintColor = [AppColor darkOverlay];
    actionSheet.blurRadius = 8.0f;
    actionSheet.animationDuration = 0.3f;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.cancelButtonTitle = NSLocalizedString(@"取消", nil);
    
    actionSheet.buttonTextAttributes = @{NSFontAttributeName: [AppFont defaultFont], NSForegroundColorAttributeName: [AppColor mainWhite]};
    actionSheet.cancelButtonTextAttributes = @{NSFontAttributeName: [AppFont defaultFont], NSForegroundColorAttributeName: [AppColor mainWhite]};
    actionSheet.destructiveButtonTextAttributes = @{NSFontAttributeName: [AppFont defaultFont], NSForegroundColorAttributeName: [AppColor mainYellow]};
    
    actionSheet.headerView = [self shareHeaderView];
    if (!self.isPage) {
        [actionSheet addButtonWithTitle:@"添加到收藏" image:[UIImage imageNamed:@"add-to-bookmark"] type:AHKActionSheetButtonTypeDestructive handler:^(AHKActionSheet *actionSheet) {
            [self addCollection];
        }];
    }
    [actionSheet addButtonWithTitle:@"分享到新浪微博" image:[UIImage imageNamed:@"weibo"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeSinaWeibo];
    }];
    [actionSheet addButtonWithTitle:@"分享到QQ空间" image:[UIImage imageNamed:@"qqzone"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeQQZone];
    }];
    [actionSheet addButtonWithTitle:@"分享给QQ好友" image:[UIImage imageNamed:@"qq"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeQQ];
    }];
    [actionSheet addButtonWithTitle:@"分享到朋友圈" image:[UIImage imageNamed:@"moments"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeMoments];
    }];
    [actionSheet addButtonWithTitle:@"分享到微信" image:[UIImage imageNamed:@"wechat"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeWechat];
    }];
    [actionSheet addButtonWithTitle:@"短信分享" image:[UIImage imageNamed:@"sms"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeSMS];
    }];
//    [actionSheet addButtonWithTitle:@"分享给社区好友" image:[UIImage imageNamed:@"send-to-friends"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
//        [self share:ShareTypeLocal];
//    }];
    [actionSheet addButtonWithTitle:@"复制链接" image:[UIImage imageNamed:@"copy-link"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeCopyURL];
    }];
    [actionSheet addButtonWithTitle:@"通过Email分享" image:[UIImage imageNamed:@"share-email"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share:ShareTypeEmail];
    }];
    [actionSheet show];
}

- (UIView *)shareHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 320)];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 10, ScreenWidth - 20, 240);
    if (self.currentPost.thumbnail){
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.currentPost.thumbnail] placeholderImage:[UIImage imageNamed:@"LaunchLOGO.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.thumbnail = image;
        }];
    } else {
        imageView.image = [UIImage imageNamed:@"LaunchLOGO.png"];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 15.0f;
    [headerView addSubview:imageView];
    self.thumbnail = imageView.image;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 270, ScreenWidth - 20, 20)];
    label1.text = self.currentPost.title;
    label1.textColor = [AppColor mainWhite];
    label1.font = [AppFont defaultFont];
    label1.backgroundColor = [AppColor transparent];
    [headerView addSubview:label1];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 300, ScreenWidth - 30, 10)];
    descLabel.text = self.currentPost.shortDescription;
    descLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
    descLabel.font = [UIFont fontWithName:@"Avenir" size:15.0f];
    descLabel.backgroundColor = [AppColor transparent];
    [headerView addSubview:descLabel];
    
    return headerView;
}

- (void)addLike {
    [User likePostByPostID:self.currentPost.postID andBlock:^(BOOL success, BOOL liked, NSUInteger credit) {
        if (success) {
            [self.likeButton setImage:[[UIImage imageNamed:@"liked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            self.likeButton.enabled = NO;
            if (liked) {
                [MozTopAlertView showWithType:MozAlertTypeWarning text:@"已经点过赞了" parentView:self.navigationController.navigationBar];
            } else {
                self.currentPost.numberOfLikes++;
                self.likeLabel.text = [NSString stringWithFormat:@"点赞 %lu 次",(unsigned long)self.currentPost.numberOfLikes];
                [TAOverlay showOverlayWithLabel:[NSString stringWithFormat:@"点赞成功，积分增加%lu",(unsigned long)credit] Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlayShadow];
            }
        } else {
            [MozTopAlertView showWithType:MozAlertTypeError text:@"点赞失败" parentView:self.navigationController.navigationBar];
        }
    }];
}

- (void)addCollection {
    [User collectPostByPostID:self.currentPost.postID forRemove:NO andBlock:^(BOOL success, BOOL collected) {
        if (success && !collected) {
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"收藏成功" parentView:self.navigationController.navigationBar];
            self.bookmarkButton.hidden = YES;
            self.currentPost.numberOfBookmarks++;
            self.bookmarkLabel.text = [NSString stringWithFormat:@"收藏 %lu 人",(unsigned long)self.currentPost.numberOfBookmarks];
            return;
        } else if (collected){
            [MozTopAlertView showWithType:MozAlertTypeWarning text:@"已收藏该文章" parentView:self.navigationController.navigationBar];
            self.bookmarkButton.hidden = YES;
            return;
        } else {
            [MozTopAlertView showWithType:MozAlertTypeError text:@"收藏失败" parentView:self.navigationController.navigationBar];
        }
    }];
}

- (void)share:(ShareType)shareType {
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:self.currentPost.shortDescription
                                     images:self.thumbnail
                                        url:[NSURL URLWithString:self.currentPost.postUrl]
                                      title:self.currentPost.title
                                       type:SSDKContentTypeAuto];
    switch (shareType) {
        case ShareTypeSinaWeibo:
        {
            [ShareSDK showShareEditor:SSDKPlatformTypeSinaWeibo
                   otherPlatformTypes:nil
                          shareParams:shareParams
                  onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                      switch (state) {
                          case SSDKResponseStateSuccess: {
                              [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          case SSDKResponseStateFail: {
                              [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          default:
                              break;
                      }
                  }];
            break;
        }
        case ShareTypeQQZone:
        {
            [ShareSDK showShareEditor:SSDKPlatformSubTypeQZone
                   otherPlatformTypes:nil
                          shareParams:shareParams
                  onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                      switch (state) {
                          case SSDKResponseStateSuccess: {
                              [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          case SSDKResponseStateFail: {
                              [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          default:
                              break;
                      }
                  }];
            break;
        }
        case ShareTypeQQ:
        {
            [ShareSDK share:SSDKPlatformSubTypeQQFriend
                 parameters:shareParams
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                 switch (state) {
                     case SSDKResponseStateSuccess: {
                         [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                         break;
                     }
                     case SSDKResponseStateFail: {
                         [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                         break;
                     }
                     default:
                         break;
                 }
             }];
            break;
        }
        case ShareTypeMoments:
        {
            [ShareSDK showShareEditor:SSDKPlatformSubTypeWechatTimeline otherPlatformTypes:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                switch (state) {
                    case SSDKResponseStateSuccess: {
                        [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    case SSDKResponseStateFail: {
                        [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    default:
                        break;
                }
            }];
            break;
        }
        case ShareTypeWechat:
        {
            [ShareSDK share:SSDKPlatformTypeWechat parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                switch (state) {
                    case SSDKResponseStateSuccess: {
                        [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    case SSDKResponseStateFail: {
                        [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    default:
                        break;
                }
            }];
            break;
        }
        case ShareTypeSMS:
        {
            [ShareSDK showShareEditor:SSDKPlatformTypeSMS
                   otherPlatformTypes:nil
                          shareParams:shareParams
                  onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                      switch (state) {
                          case SSDKResponseStateSuccess: {
                              [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          case SSDKResponseStateFail: {
                              [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                              break;
                          }
                          default:
                              break;
                      }
                  }];
            break;
        }
        case ShareTypeLocal:
//#warning TODO:
            break;
        case ShareTypeCopyURL:
        {
            [ShareSDK share:SSDKPlatformTypeCopy parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                switch (state) {
                    case SSDKResponseStateSuccess:
                        [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"链接复制成功!", nil) parentView:self.navigationController.navigationBar];
                        break;
                    case SSDKResponseStateFail:
                        [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"链接复制失败", nil) parentView:self.navigationController.navigationBar];
                    default:
                        break;
                }
            }];
            break;
        }
        case ShareTypeEmail:
        {
            [ShareSDK share:SSDKPlatformTypeMail parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                switch (state) {
                    case SSDKResponseStateSuccess: {
                        [MozTopAlertView showWithType:MozAlertTypeSuccess text:NSLocalizedString(@"分享成功", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    case SSDKResponseStateFail: {
                        [MozTopAlertView showWithType:MozAlertTypeError text:NSLocalizedString(@"分享失败", nil) parentView:self.navigationController.navigationBar];
                        break;
                    }
                    default:
                        break;
                }
            }];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Delegate Methods

- (void)viewMorePostWithAuthorID:(NSUInteger)authorID {
    SortPostTableViewController *sortPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SortPostTVC"];
    sortPostVC.identification = authorID;
    sortPostVC.sortType = PostSortTypeAuthor;
    sortPostVC.title = [NSString stringWithFormat:@"%@的文章",self.currentPost.author.name];
    
    [self.navigationController pushViewController:sortPostVC animated:YES];
}

- (void)avatarDidTap {
    [self avatarDidTapAtUser:self.currentPost.author];
}

- (void)replyDidTapAtCommentID:(NSUInteger)commentID withName:(NSString *)name inRowID:(NSUInteger)rowID {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowID inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    self.commentInput.placeholder = [NSString stringWithFormat:@"回复给%@:...",name];
    self.commentTo = commentID;
    [self.commentInput becomeFirstResponder];
}

- (void)avatarDidTapAtUser:(User *)user {
    if (!user) {
        return;
    }
    PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPageTVC.currentUser = user;
    [self.navigationController pushViewController:personalPageTVC animated:YES];
}

- (void)nameDidTapAtUser:(User *)user {
    if (!user) {
        return;
    }
    PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPageTVC.currentUser = user;
    [self.navigationController pushViewController:personalPageTVC animated:YES];
}

- (void)showPhotos:(NSArray *)images atIndex:(NSUInteger)index {
    self.photos = [NSMutableArray array];
    for (NSString *url in images) {
        MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc]init];
        photo.photoURL = [NSURL URLWithString:url];
        UIImageView *imageView = self.headerController.imageViews[index];
        photo.toView = imageView;
        [self.photos addObject:photo];
    }
    
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc] init];
    photoBrowser.status = UIViewAnimationAnimationStatusZoom;
    photoBrowser.editing = NO;
    photoBrowser.photos = self.photos;
    photoBrowser.delegate = self;
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self presentViewController:photoBrowser animated:NO completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.currentPost.comments.count;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return AUTHOR_TABLE_CELL_HEIGHT;
        case 1:
        {
            Comment *currentComment = nil;
            if (![self.currentPost.comments[indexPath.row] isKindOfClass:[Comment class]]) {
                currentComment = [Comment commentWithAttributes:self.currentPost.comments[indexPath.row]];
            } else {
                currentComment = self.currentPost.comments[indexPath.row];
            }
            return ([[NSString filterHTML:currentComment.content] length] / 25) * 18 + 90;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            AuthorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:authorCellReuse forIndexPath:indexPath];
            
            cell.author = self.currentPost.author;
            cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.45];
            
            cell.delegate = self;
            
            if (IOS_VERSION_9_OR_ABOVE) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
            
            return cell;
        }
        case 1:
        {
            CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellReuse forIndexPath:indexPath];
            if (IOS_VERSION_9_OR_ABOVE) {
                if (!cell.currentComment) {
                    [self registerForPreviewingWithDelegate:self sourceView:cell];
                }
            }
            cell.rowID = indexPath.row;
            Comment *currentComment = [Comment new];
            if ([self.currentPost.comments[indexPath.row] isKindOfClass:[Comment class]]) {
                currentComment = self.currentPost.comments[indexPath.row];
            } else {
                currentComment = [Comment commentWithAttributes:self.currentPost.comments[indexPath.row]];
            }
    
            cell.membershipType = currentComment.author.membership;
            [cell setCurrentComment:currentComment];
            
            cell.nameLabel.textColor = [AppColor loginButtonColor];
            
            NSUInteger currentCommentParent = currentComment.parent;
            NSUInteger currentIndex = 0;
            if (currentComment.parent) {
                NSString *commentParentAuthorName = nil;
                for (NSDictionary *commentAttributes in self.currentPost.comments) {
                    Comment *comment = [Comment commentWithAttributes:commentAttributes];
                    currentIndex++;
                    if (comment.commentID == currentCommentParent) {
                        commentParentAuthorName = comment.author.name;
                        break;
                    }
                }
                cell.nameLabel.text = [NSString stringWithFormat:@"%@ 回复给 %@(%lu楼)",currentComment.author.name,commentParentAuthorName,(unsigned long)currentIndex];
            } else {
                cell.nameLabel.text = [NSString stringWithFormat:@"%@",currentComment.author.name];
            }
            cell.replyButton.titleLabel.text = NSLocalizedString(@"回复", nil);
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
                cell.replyButton.enabled = NO;
            }
            if (currentComment.author.userID == self.currentPost.author.userID) {
                cell.authorIdenficationLabel.text = NSLocalizedString(@"楼主", nil);
                [cell.authorIdenficationLabel setBackgroundColor:[AppColor mainYellow]];
                cell.authorIdenficationLabel.layer.masksToBounds = YES;
                cell.authorIdenficationLabel.layer.cornerRadius = 5.0f;
            } else {
                cell.authorIdenficationLabel.text = @"";
                [cell.authorIdenficationLabel setBackgroundColor:[AppColor transparent]];
            }
            
            cell.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
            
            cell.delegate = self;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        default:
            return nil;
    }
}

- (void)closeViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ===== 3D Touch ====== (iOS 9 Only)

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.commentInput isFirstResponder]) {
        [self.commentInput resignFirstResponder];
    }
    if ([previewingContext.sourceView isKindOfClass:[AuthorTableViewCell class]]) {
        PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
        
        personalPage.currentUser = self.currentPost.author;
        personalPage.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        
        personalPage.delegate = self;
        
        return personalPage;
    }
    
    if ([previewingContext.sourceView isKindOfClass:[CommentTableViewCell class]]) {
        PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
        
        CommentTableViewCell *previewingCell = (CommentTableViewCell *)previewingContext.sourceView;
        personalPage.currentUser = previewingCell.currentComment.author;
        personalPage.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        
        personalPage.delegate = self;
        
        return personalPage;
    }
    
    if ([previewingContext.sourceView isKindOfClass:[UIImageView class]]) {
        UIImageView *previewingImageView = (UIImageView *)previewingContext.sourceView;
        if ([previewingImageView.image isEqual:[UIImage imageNamed:@"video-thumbnail"]]) {
            UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
            [webBrowser.rootWebBrowser loadURLString:self.headerController.videos[previewingImageView.tag]];
            return webBrowser;
        } else {
            SingleImageViewController *imageController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleImage"];
            imageController.displayImage = previewingImageView.image;
            imageController.imageURL = self.headerController.imagesWithAttribute[previewingImageView.tag][@"url"];
            
            imageController.preferredContentSize = previewingImageView.frame.size;
            imageController.delegate = self;
            
            return imageController;
        }
        
    }
    
    if ([previewingContext.sourceView isKindOfClass:[UILabel class]]) {
        UILabel *previewingLabel = (UILabel *)previewingContext.sourceView;
        UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
        [webBrowser.rootWebBrowser loadURLString:self.headerController.links[previewingLabel.tag]];
        return webBrowser;
    }
    
    return [UIViewController new];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    if ([viewControllerToCommit isKindOfClass:[UINavigationController class]]) {
        [self presentViewController:viewControllerToCommit animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:viewControllerToCommit animated:YES];
    }
}

- (void)followActionSucceeded:(PersonalPageFollowStatus)status {
    switch (status) {
        case PersonalPageFollowStatusFollowedEachOther:
        case PersonalPageFollowStatusFollowed:
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"关注成功" parentView:self.navigationController.navigationBar];
            break;
        default:
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"取消关注成功" parentView:self.navigationController.navigationBar];
            break;
    }
}

- (void)imageSaved:(BOOL)success {
    if (success) {
        [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"保存成功" parentView:self.navigationController.navigationBar];
    } else {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"保存失败" parentView:self.navigationController.navigationBar];
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:[UIPreviewAction actionWithTitle:@"新浪微博" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeSinaWeibo];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"QQ空间" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeQQZone];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"QQ好友" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeQQ];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"微信朋友圈" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeMoments];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"微信好友" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeWechat];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"复制链接" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeCopyURL];
    }]];
    [actions addObject:[UIPreviewAction actionWithTitle:@"Email" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self share:ShareTypeEmail];
    }]];
    
    return @[[UIPreviewAction actionWithTitle:@"收藏" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self addCollection];
    }],[UIPreviewActionGroup actionGroupWithTitle:@"分享" style:UIPreviewActionStyleDefault actions:actions]];
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
