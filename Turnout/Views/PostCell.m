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

- (void)setCell{
    [self queryLikes];
    [self updateLikes];
    PFUser *user = self.post.author;
    [user fetchIfNeeded];
    self.nameLabel.text = user[@"username"];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timeAgo;
    if(self.post.photoAttached){
        [self loadImage];
    } else {
        [self checkImageView];
    }
    //     [self loadImage];
}

- (void)checkImageView{
    [self.attachedPhoto removeFromSuperview];
    self.attachedPhoto = nil;
}

- (void)loadImage{
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:data];
            self.attachedPhoto.image = img;
        }else{
            NSLog(@"Print error!!! %@", error.localizedDescription);
        }
    }];
}

- (void)queryLikes{
    PFQuery *query = [PFQuery queryWithClassName:@"Assoc"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"typeId" equalTo:@"Like"];
    [query whereKey:@"likedPost" equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *assocs, NSError *error) {
        if (assocs != nil) {
            self.assocs = assocs;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)updateLikes{
    UIImage *likeIcon;
    if(self.assocs.count == 0 || [self checkIfUserLiked]){
        likeIcon = [UIImage imageNamed:@"notliked.png"];
    } else {
        likeIcon = [UIImage imageNamed:@"liked.png"];
    }
    NSString *likeCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.assocs.count];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setImage:likeIcon forState:UIControlStateNormal];
}

- (IBAction)likeTapped:(id)sender {
    [self createLikeAssoc];
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
    
}

- (BOOL)checkIfUserLiked{
    PFUser *currentUser = PFUser.currentUser;
    for(Assoc *assoc in self.assocs){
        if(assoc.user == currentUser){
            return YES;
        }
    }
    return NO;
}

@end
