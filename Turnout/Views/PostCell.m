//
//  PostCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PostCell.h"
#import "Assoc.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    BOOL hasContentView = [self.subviews containsObject:self.contentView];
    if (hasContentView) {
        [self.contentView removeFromSuperview];
    }
}

- (void)setCell{
    [self updateLikes];
    PFUser *user = self.post.author;
    [user fetchIfNeeded];
    self.nameLabel.text = user[@"username"];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timeAgo;
    [self loadImage];
}

- (void)loadImage{
    self.attachedPhoto.file = self.post.image;
    [self.attachedPhoto loadInBackground];
}

-(void)updateLikes{
    UIImage *likeIcon;
    if([self checkIfUserLiked]){
         likeIcon = [UIImage imageNamed:@"liked.png"];
    } else {
        likeIcon = [UIImage imageNamed:@"notliked.png"];
    }
    NSString *likeCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.post.likeAssocs.count];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
}

- (IBAction)likeTapped:(id)sender {
    if([self checkIfUserLiked]){
        [self removeLikeAssoc];
    } else {
        [self createLikeAssoc];
    }
}

- (void)createLikeAssoc{
    Assoc *likeAssoc = [Assoc new];
    PFUser *currentUser = PFUser.currentUser;
    likeAssoc.user = currentUser;
    likeAssoc.likedPost = self.post;
    likeAssoc.typeId = @"Like";
    [likeAssoc saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The assoc was saved!");
            [self updateLikes];
        } else {
            NSLog(@"Problem saving assoc: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeAssoc{
    Assoc *usersLike = [self queryUsersLike];
    [usersLike deleteInBackground];
    [self updateLikes];
}

- (BOOL)checkIfUserLiked{
    if([self queryUsersLike]) return YES;
    else return NO;
}

- (Assoc *)queryUsersLike{
    PFUser *currentUser = PFUser.currentUser;
    for(Assoc *like in self.post.likeAssocs){
        if(like.user == currentUser){
            return like;
        }
    }
    return nil;
}

@end
