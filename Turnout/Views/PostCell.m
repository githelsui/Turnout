//
//  PostCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PostCell.h"
#import "Assoc.h"
#import "Zipcode.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

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

- (void)setTimer{
    PFUser *currentUser = PFUser.currentUser;
    if(currentUser || [FBSDKAccessToken currentAccessToken]){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
            NSTimer *timer = [NSTimer timerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(setCell)
                                                   userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
            });
        });
    }
}

- (void)setCell{
    self.likeAnimation.alpha = 0;
    [self updateLikes];
    [self queryLikes];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timeAgo;
    [self loadImage];
    PFUser *user = self.post.author;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if(user){
            self.nameLabel.text = user[@"username"];
            [self getPostLocation:user];
        }
    }];
}

- (void)getPostLocation:(PFObject *)user{
    Zipcode *zip = user[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *location = [NSString stringWithFormat:@"%@, %@", zipcode[@"city"], zipcode[@"shortState"]];
            self.locationLabel.text = location;
        }
    }];
}

- (void)loadImage{
    self.attachedPhoto.image = [UIImage imageNamed:@"..."];
    self.attachedPhoto.file = self.post.image;
    [self.attachedPhoto loadInBackground];
}

- (void)queryLikes{
    PFQuery *query = [PFQuery queryWithClassName:@"Assoc"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"typeId" equalTo:@"Like"];
    [query whereKey:@"likedPost" equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *assocs, NSError *error) {
        if (assocs != nil) {
            self.assocs = assocs;
            [self updateLikes];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)updateLikes{
    UIImage *likeIcon;
    if(![self checkIfUserLiked]){
        likeIcon = [UIImage imageNamed:@"notliked.png"];
    } else {
        likeIcon = [UIImage imageNamed:@"liked.png"];
    }
    NSString *likeCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.assocs.count];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
}

- (IBAction)likeTapped:(id)sender {
    UIImage *likeIcon;
    if([self checkIfUserLiked]){
        likeIcon = [UIImage imageNamed:@"notliked.png"];
        long newCount = self.assocs.count - 1;
        NSString *likeCount = [NSString stringWithFormat:@"%lu", newCount];
        [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
        [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
        [self removeLikeAssoc];
    } else {
        likeIcon = [UIImage imageNamed:@"liked.png"];
        long newCount = self.assocs.count + 1;
        NSString *likeCount = [NSString stringWithFormat:@"%lu", newCount];
        [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
        [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
        [self createLikeAssoc];
    }
}

- (void)doubleTapped {
    UIImage *likeIcon;
    if([self checkIfUserLiked]){
        self.likeAnimation.image = [UIImage imageNamed:@"largeUnlike.png"];
        likeIcon = [UIImage imageNamed:@"notliked.png"];
        long newCount = self.assocs.count - 1;
        NSString *likeCount = [NSString stringWithFormat:@"%lu", newCount];
        [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
        [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
        [self removeLikeAssoc];
    } else {
        self.likeAnimation.image = [UIImage imageNamed:@"largeLike.png"];
        likeIcon = [UIImage imageNamed:@"liked.png"];
        long newCount = self.assocs.count + 1;
        NSString *likeCount = [NSString stringWithFormat:@"%lu", newCount];
        [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
        [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
        [self createLikeAssoc];
    }
    [self loadLikeAnim];
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
            [self addLikeCount];
        } else {
            NSLog(@"Problem saving assoc: %@", error.localizedDescription);
        }
    }];
}

- (void)addLikeCount{
    self.post.likeCount = @([self.post.likeCount intValue] + [@1 intValue]);
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeCount{
    self.post.likeCount = @([self.post.likeCount intValue] - [@1 intValue]);
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeAssoc{
    Assoc *usersLike = [self usersLike];
    [usersLike deleteInBackground];
    [self removeLikeCount];
}

- (BOOL)checkIfUserLiked{
    [self queryUsersLike];
    if(self.userLiked.count == 0) return NO;
    else return YES;
}

- (Assoc *)usersLike{
    [self queryUsersLike];
    return self.userLiked[0];
}

- (void)queryUsersLike{
    PFUser *currentUser = PFUser.currentUser;
    PFQuery *query = [PFQuery queryWithClassName:@"Assoc"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"typeId" equalTo:@"Like"];
    if(currentUser) [query whereKey:@"user" equalTo:currentUser];
    [query whereKey:@"likedPost" equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *assocs, NSError *error) {
        if (assocs != nil) {
            self.userLiked = assocs;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)loadLikeAnim{
    [UIView animateWithDuration:0.3 animations:^{
        self.likeAnimation.alpha = 1;
    }];
    [UIView animateWithDuration:1 animations:^{
        self.likeAnimation.alpha = 1;
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.likeAnimation.alpha = 0;
    }];
}

@end
