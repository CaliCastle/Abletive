//
//  PostTableViewCell.h
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "UserCollection.h"
#import "UIImageView+WebCache.h"

@interface PostTableViewCell : UITableViewCell

@property (nonatomic,strong) Post * _Nullable post;
@property (nonatomic,strong) NSDictionary * _Nullable rawPost;

@property (nonatomic,strong)  UserCollection * _Nullable userCollection;

@property (weak, nonatomic) IBOutlet UILabel * _Nullable titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable authorLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable dateLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable visitLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable commentLabel;
@property (weak, nonatomic) IBOutlet UIImageView * _Nullable thumbnail;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable shortDescLabel;

@end
