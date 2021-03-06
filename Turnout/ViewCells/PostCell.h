//
//  PostCell.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/PFImageView.h>
NS_ASSUME_NONNULL_BEGIN

@protocol PostCellDelegate
- (void)refreshFeed;
@end

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *zipcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet PFImageView *attachedPhoto;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSArray *assocs;
@property (nonatomic, strong) NSArray *userLiked;
@property (weak, nonatomic) IBOutlet UIImageView *likeAnimation;
@property (nonatomic, weak) id<PostCellDelegate> delegate;
- (void)doubleTapped;
- (void)setCell;
+ (NSString *)reuseIdentifier;
+ (void)registerIn:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
