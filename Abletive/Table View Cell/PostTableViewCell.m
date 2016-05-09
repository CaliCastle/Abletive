//
//  PostTableViewCell.m
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostTableViewCell.h"
#import "CCDateToString.h"

@interface PostTableViewCell()

@end

@implementation PostTableViewCell

- (void)setPost:(Post *)post {
    _post = post;
    if (![_post.imageMediumPath isEqualToString:@""]) {
        [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:_post.imageMediumPath] placeholderImage:[UIImage imageNamed:@"post_placeholder"] options:SDWebImageContinueInBackground | SDWebImageHighPriority];
    }
    else if (![_post.imageFullPath isEqualToString:@""]) {
        [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:_post.imageFullPath] placeholderImage:[UIImage imageNamed:@"post_placeholder"] options:SDWebImageContinueInBackground | SDWebImageHighPriority];
    }
    else {
        self.thumbnail.image = [UIImage imageNamed:@"post_placeholder"];
    }
    self.titleLabel.text = _post.title;
    self.authorLabel.text = _post.author.name;
    self.dateLabel.text = [CCDateToString getStringFromDate:_post.date];
    self.visitLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_post.visitCount];
    self.commentLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_post.commentCount];
    self.categoryLabel.text = [_post.belongedCategories firstObject][@"title"];
    self.shortDescLabel.text = _post.shortDescription;
    
    [self setNeedsLayout];
}

- (void)setRawPost:(NSDictionary *)rawPost {
    _rawPost = rawPost;
    if (![_rawPost[@"thumbnail"] isEqualToString:@""]) {
        [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:_rawPost[@"thumbnail"]] placeholderImage:[UIImage imageNamed:@"post_placeholder"] options:SDWebImageContinueInBackground | SDWebImageHighPriority];
    } else {
        self.thumbnail.image = [UIImage imageNamed:@"post_placeholder"];
    }
    self.titleLabel.text = _rawPost[@"title"];
    self.authorLabel.text = _rawPost[@"author_name"];
    self.dateLabel.text = [CCDateToString getStringFromDate:_rawPost[@"date"]];
    self.visitLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_rawPost[@"visit_count"]];
    self.commentLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_rawPost[@"comment_count"]];
    self.categoryLabel.text = _rawPost[@"category"][@"title"];
    self.shortDescLabel.text = _rawPost[@"description"];
}

- (void)setUserCollection:(UserCollection *)userCollection {
    _userCollection = userCollection;
    
    if (_userCollection.thumbnail) {
        [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:_userCollection.thumbnail] placeholderImage:[UIImage imageNamed:@"post_placeholder"] options:SDWebImageContinueInBackground];
    }
    self.titleLabel.text = _userCollection.title;
    self.authorLabel.text = _userCollection.authorName;
    self.dateLabel.text = _userCollection.date;
    self.dateLabel.font = [UIFont systemFontOfSize:7];
    self.visitLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_userCollection.views];
    self.commentLabel.text = _userCollection.commentCount;
    self.categoryLabel.text = _userCollection.categoryName;
    self.shortDescLabel.text = _userCollection.excerpt;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
