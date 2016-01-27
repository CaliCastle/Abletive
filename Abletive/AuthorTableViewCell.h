//
//  AuthorTableViewCell.h
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol AuthorCellDelegate <NSObject>

- (void)viewMorePostWithAuthorID:(NSUInteger)authorID;
- (void)avatarDidTap;

@end


@interface AuthorTableViewCell : UITableViewCell

@property (weak,nonatomic) id<AuthorCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *authorAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *authorTagButton;
@property (weak, nonatomic) IBOutlet UIButton *authorPostButton;

@property (nonatomic,strong) User *author;

@end
