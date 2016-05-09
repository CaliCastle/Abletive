//
//  CommentTableViewCell.h
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@protocol CommentCellDelegate <NSObject>

- (void)replyDidTapAtCommentID:(NSUInteger)commentID withName:(NSString *)name inRowID:(NSUInteger)rowID;
- (void)avatarDidTapAtUser:(User *)user;
- (void)nameDidTapAtUser:(User *)user;
- (void)linkDidTapAtURL:(NSString *)url;

@end

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic,weak) id<CommentCellDelegate> delegate;

@property (nonatomic,strong) Comment *currentComment;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UILabel *rowLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorIdenficationLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *membershipImageView;

@property (nonatomic,assign) UserMembershipType membershipType;

@property (nonatomic,assign) NSUInteger rowID;

- (instancetype)initWithComment:(Comment *)currentComment;

@end
