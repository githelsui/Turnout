//
//  PostCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
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

- (void)setCell{
    self.likeAnimation.alpha = 0;
    self.bubbleView.layer.cornerRadius = 15;
    self.bubbleView.clipsToBounds = true;
    self.bubbleView.layer.masksToBounds = NO;
    self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bubbleView.layer.shadowRadius = 0.5;
    self.bubbleView.layer.shadowOpacity = 0.5;
    [self updateLikes];
    self.statusLabel.text = self.post.status;
    [self getTimeAgo];
    [self loadImage];
    PFUser *user = self.post.author;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if(user){
            self.nameLabel.text = user[@"username"];
            [self getPostLocation:user];
        }
    }];
}

- (void)getTimeAgo{
    NSString *timeAgoStr = [self.post getTimeAgo:self.post];
    self.timeLabel.text = timeAgoStr;
}

- (void)getPostLocation:(PFObject *)user{
    Zipcode *zip = user[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *location = [NSString stringWithFormat:@"%@, %@", zipcode[@"city"], zipcode[@"shortState"]];
            self.locationLabel.text = location;
            self.zipcodeLabel.text = zipcode[@"zipcode"];
        }
    }];
}

- (void)loadImage{
    self.attachedPhoto.image = [UIImage imageNamed:@"..."];
    self.attachedPhoto.file = self.post.image;
    self.attachedPhoto.clipsToBounds = YES;
    self.attachedPhoto.layer.cornerRadius = 15;
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
    NSNumber *likes = self.post.likeCount;
    NSString *likeCount = [NSString stringWithFormat:@"%@", likes];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
}

- (IBAction)likeTapped:(id)sender {
    [self likeFunctionality];
}

- (void)doubleTapped {
    [self likeFunctionality];
    [self loadLikeAnim];
}

- (void)likeFunctionality{
    if([self checkIfUserLiked]){
        [self removeLikeCount];
        [self removeLikeAssoc];
    } else {
        [self addLikeCount];
        [self createLikeAssoc];
    }
    [self.delegate refreshFeed];
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
        } else {
            NSLog(@"Problem saving assoc: %@", error.localizedDescription);
        }
    }];
}

- (void)addLikeCount{
    NSNumber *newCount = @([self.post.likeCount intValue] + [@1 intValue]);
    self.post.likeCount = newCount;
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The count was saved!");
            [self updateLikes];
        } else {
            NSLog(@"Problem saving count: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeCount{
    NSNumber *newCount = @([self.post.likeCount intValue] - [@1 intValue]);
    self.post.likeCount = newCount;
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The count was saved!");
        } else {
            NSLog(@"Problem saving count: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeAssoc{
    Assoc *usersLike = [self usersLike];
    [usersLike deleteInBackground];
    [self updateLikes];
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
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.likeAnimation.alpha = 1;
        self.bubbleView.backgroundColor = [UIColor colorWithRed:255/255.0f
                                                          green:170/255.0f
                                                           blue:146/255.0f
                                                          alpha:1.0f];
    } completion:^(BOOL finished) {
        [self returnOriginalState];
    }];
}

- (void)returnOriginalState{
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.likeAnimation.alpha = 0;
        self.bubbleView.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
    }];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (void)registerIn:(UITableView *)tableView {
    [tableView registerClass:self.class
      forCellReuseIdentifier:[self reuseIdentifier]];
}

@end
