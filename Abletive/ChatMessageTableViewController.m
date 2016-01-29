//
//  ChatMessageTableViewController.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ChatMessageTableViewController.h"
#import "MessagePlainTableViewCell.h"
#import "MessageTimeTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AppColor.h"
#import "STInputBar.h"
#import "TAOverlay.h"
#import "KINWebBrowser/KINWebBrowserViewController.h"
#import "PersonalPageTableViewController.h"
#import "SinglePostTableViewController.h"

@interface ChatMessageTableViewController ()<UITableViewDataSource,UITableViewDelegate,MessageTableViewDelegate>

@property (nonatomic,strong) NSMutableArray *allMessages;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) STInputBar *inputBar;

@property (nonatomic,assign) BOOL isKeyboardOpen;
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) CGFloat barHeight;

@end

@implementation ChatMessageTableViewController {
    BOOL animationLock;
    BOOL messageLoaded;
}

- (NSMutableArray *)allMessages {
    if (_allMessages) {
        return _allMessages;
    }
    
    _allMessages = [NSMutableArray array];
    
    return _allMessages;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    
    _tableView                      =   [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.inputBar.frame.size.height)];
    _tableView.fd_debugLogEnabled   =   NO;
    _tableView.separatorStyle       =   UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor      =   [AppColor secondaryBlack];
    _tableView.delegate             =   self;
    _tableView.dataSource           =   self;
    _tableView.keyboardDismissMode  =   UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.indicatorStyle       =   UIScrollViewIndicatorStyleWhite;
    
    [_tableView registerClass:[MessagePlainTableViewCell class] forCellReuseIdentifier:kCellReuseIDWithSenderAndType(0,(long)ChatMessageTypePlainText)];
    [_tableView registerClass:[MessagePlainTableViewCell class] forCellReuseIdentifier:kCellReuseIDWithSenderAndType(1, (long)ChatMessageTypePlainText)];
    [_tableView registerClass:[MessageTimeTableViewCell class] forCellReuseIdentifier:kTimeCellReusedID];
    
    return _tableView;
}

- (STInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [STInputBar new];
        _inputBar.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.inputBar.frame) + CGRectGetHeight(self.inputBar.frame)/2);
        _inputBar.fitWhenKeyboardShowOrHide = YES;
    }
    return _inputBar;
}

- (void)setupInputBar {
    __weak typeof(self) weakSelf = self;
    self.barHeight = self.inputBar.frame.size.height;
    [self.inputBar setDidSendClicked:^(NSString *text) {
        [weakSelf sendMessage:text];
    }];
    [self.inputBar setInputBarSizeChangedHandle:^(CGFloat height) {
        [weakSelf inputBarSizeWillChange:height];
    }];
    [self.view addSubview:self.inputBar];
}

- (void)fetchMessages {
    [TAOverlay showOverlayWithLogo];
    if (!self.currentUser) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [User getUserinfoWithID:self.userID andBlock:^(User * _Nullable user, NSError * _Nullable error) {
                if (!error) {
                    self.currentUser = user;
                    [ChatMessage getChatMessagesFromUserID:self.currentUser.userID andBlock:^(NSArray *chatMessages) {
                        [self messagesLoaded:chatMessages];
                    }];
                    [self setupUser];
                } else {
                    [TAOverlay showOverlayWithErrorText:@"加载失败, 请重试"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ChatMessage getChatMessagesFromUserID:self.currentUser.userID andBlock:^(NSArray *chatMessages) {
                [self messagesLoaded:chatMessages];
            }];
        });
    }
}

- (void)setupUser {
    self.title = self.currentUser.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"author"] style:UIBarButtonItemStyleDone target:self action:@selector(avatarDidTap)];
}

- (void)messagesLoaded:(NSArray *)chatMessages {
    [TAOverlay hideOverlay];
    if (chatMessages) {
        messageLoaded = YES;
        if (chatMessages.count) {
            [self.allMessages addObjectsFromArray:chatMessages];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        } else {
            ChatMessage *helloMessage = [ChatMessage chatMessageWithContent:@"Hi😄, 我们还没聊过天呢，想找我说些什么？" andType:ChatMessageTypePlainText andIsSender:NO withUserID:self.currentUser.userID];
            [self.allMessages addObject:helloMessage];
            [self.tableView reloadData];
        }
    } else {
        [TAOverlay showOverlayWithErrorText:@"加载失败, 请重试"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchMessages];
    [self setupUser];
    
    self.lastPoint = CGPointZero;
    
    self.view.backgroundColor = [AppColor secondaryBlack];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.tableView];
    [self setupInputBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self keyboardEvent:aNotification and:YES];
    self.isKeyboardOpen = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self keyboardEvent:aNotification and:NO];
    self.isKeyboardOpen = NO;
}

- (void)keyboardEvent:(NSNotification *)aNotification and:(BOOL)isOpen {
    if (!messageLoaded) {
        return;
    }
    
    if (isOpen) {
        self.tableView.frame = CGRectMake(self.lastPoint.x, self.lastPoint.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.lastPoint = self.tableView.frame.origin;
    }
    NSDictionary *userInfo = aNotification.userInfo;
    NSTimeInterval animationDuration = 0;
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseIn;
    CGRect keyboardFrame = CGRectZero;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat contentSizeHeight = self.tableView.contentSize.height + self.navigationController.navigationBar.frame.size.height;
    
    if (self.tableView.frame.size.height - keyboardFrame.size.height >= contentSizeHeight) {
        
    } else {
        if (self.isKeyboardOpen && isOpen) {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (keyboardFrame.size.height * (isOpen ? -1 : 1)), self.tableView.frame.size.width, self.tableView.frame.size.height);
        } else {
            if (animationLock && !isOpen) {
                animationLock = NO;
                return;
            }
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:animationCurve];
            [UIView setAnimationDuration:animationDuration];
            
            if (contentSizeHeight >= self.tableView.frame.size.height) {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (keyboardFrame.size.height * (isOpen ? -1 : 1)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            } else {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (isOpen ? -1 : 1) * (contentSizeHeight - (self.tableView.frame.size.height - keyboardFrame.size.height)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            }
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [UIView commitAnimations];
            if (!isOpen && self.tableView.isDragging) {
                animationLock = YES;
            }
        }
    }
    
}

- (void)inputBarSizeWillChange:(CGFloat)height {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - height + self.barHeight);
    self.barHeight = height;
}

- (void)sendMessage:(NSString *)text {
    if ([[text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        return;
    }
    ChatMessage *newMessage = [ChatMessage chatMessageWithContent:text andType:ChatMessageTypePlainText andIsSender:YES withUserID:self.currentUser.userID];
    newMessage.status = MessageSendStatusSending;
    [self.allMessages addObject:newMessage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:newMessage.isSender?UITableViewRowAnimationRight:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [ChatMessage sendChatMessageWithContent:text andToWhom:self.currentUser.userID andBlock:^(BOOL success, ChatMessage *message) {
        self.allMessages[indexPath.row] = message;
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)avatarDidTap {
    [self avatarDidTap:NO];
}

- (void)avatarDidTap:(BOOL)isMyself {
    // User tapped the sender's avatar
    PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPage.currentUser = isMyself ? nil : self.currentUser;
    
    [self.navigationController pushViewController:personalPage animated:YES];
}

- (void)linkDidTapAtURL:(NSString *)url {
    if ([url containsString:@"http://abletive.com/"]) {
        SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postSlug = url;
        
        [self.navigationController pushViewController:singlePostTVC animated:YES];
    } else {
        KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
        [self.navigationController pushViewController:webBrowser animated:YES];
        [webBrowser loadURLString:url];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *model = self.allMessages[indexPath.row];
    if (!model.isSender) {
        model.avatarURL = self.currentUser.avatarPath;
    }
    
    NSInteger height = model.height;
    
    if (!height){
        height = [tableView fd_heightForCellWithIdentifier:kCellReuseID(model) configuration:^(MessageBaseTableViewCell* cell)
                  {
                      [cell setMessageModel:model];
                  }];
    }
    
    return height+2;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.allMessages.count;
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *model = self.allMessages[indexPath.row];
    MessageBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID(model)];
    cell.delegate = self;
    // Configure the cell...
    [cell setMessageModel:model];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
