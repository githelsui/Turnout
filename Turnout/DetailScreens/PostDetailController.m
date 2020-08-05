//
//  PostDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PostDetailController.h"
#import "Assoc.h"
#import "Zipcode.h"
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKSharingContent.h>
#import <FBSDKSharePhoto.h>
#import <FBSDKShareLinkContent.h>
#import <FBSDKShareMediaContent.h>
#import <FBSDKShareDialog.h>
#import <FBSDKShareButton.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <Parse/PFImageView.h>
#import <MASUtilities.h>
#import <View+MASAdditions.h>

@interface PostDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet PFImageView *attachedPhoto;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesBtn;
@property (weak, nonatomic) IBOutlet UIImageView *likeAnimation;
@property (nonatomic, strong) NSArray *assocs;
@property (weak, nonatomic) IBOutlet UILabel *zipcodeLabel;
@property (nonatomic, strong) NSArray *userLiked;
@end

@implementation PostDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"goback" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self createShadows];
    [self setUI];
    [self updateLikes];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queryLikes) userInfo:nil repeats:true];
}

- (void)setScroll{
    [self.scrollView setScrollEnabled:YES];
    self.scrollView.frame = self.view.frame;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

- (void)setUI{
    self.likeAnimation.alpha = 0;
    PFUser *user = self.post.author;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error){
        if(user){
            self.nameLabel.text = user[@"username"];
            [self getPostLocation:user];
        }
    }];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timePosted;
    self.dateLabel.text = self.post.datePosted;
//    [self checkImageView];
    [self loadImage];
    if(![FBSDKAccessToken currentAccessToken]){
        self.shareButton.alpha = 0;
    }
}

- (void)createShadows{
    self.bubbleView.clipsToBounds = NO;
    self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bubbleView.layer.shadowRadius = 5;
    self.bubbleView.layer.shadowOpacity = 0.5;
    self.bubbleView.layer.cornerRadius = 15;
}

- (IBAction)tapFacebookShare:(id)sender {
    [self facebookShare];
}

- (void)facebookShare{
    if([FBSDKAccessToken currentAccessToken]){
        FBSDKShareMediaContent *content = [FBSDKShareMediaContent new];
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        FBSDKShareLinkContent *status = [[FBSDKShareLinkContent alloc] init];
        status.quote = self.statusLabel.text;
        photo.image = self.attachedPhoto.image;
        photo.userGenerated = YES;
        content.media = @[photo, status];
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeShareSheet;
        [dialog show];
    }
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
    [self.attachedPhoto loadInBackground];
}

- (void)checkImageView{
    if(self.post.image == nil){
        [self.attachedPhoto removeFromSuperview];
        self.attachedPhoto = nil;
                self.locationLabel.translatesAutoresizingMaskIntoConstraints = YES;
                self.zipcodeLabel.translatesAutoresizingMaskIntoConstraints = YES;
                self.likesBtn.translatesAutoresizingMaskIntoConstraints = YES;
                self.statusLabel.translatesAutoresizingMaskIntoConstraints = YES;
        
        //        CGFloat screenWidth = self.bubbleView.bounds.size.width;
        //        CGFloat locationWidth = self.locationLabel.layer.frame.size.width;
        //        CGSize statusSize = self.statusLabel.layer.frame.size;
        //        CGPoint statusPos = self.statusLabel.layer.position;
        //        CGPoint locPoint;
        //        locPoint.x = (screenWidth + locationWidth - statusSize.width) / 2;
        //        locPoint.y = statusSize.height + statusPos.y + 20;
        //        CGPoint likePoint;
        //        likePoint.x = screenWidth - self.likesBtn.layer.frame.size.width;
        //        likePoint.y = locPoint.y;
        //        self.locationLabel.layer.position = locPoint;
        //        self.likesBtn.layer.position = likePoint;
        
        [self.bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGRect frame = self.statusLabel.frame;
            frame.size.height = self.statusLabel.intrinsicContentSize.height;
            self.statusLabel.frame = frame;
            CGFloat statusHeight = frame.size.height;
            CGFloat nameHeight = self.nameLabel.frame.size.height;
            CGFloat locHeight = self.locationLabel.frame.size.height;
            CGFloat zipcodeHeight = self.zipcodeLabel.frame.size.height;
            CGFloat total = statusHeight + nameHeight + locHeight + zipcodeHeight;
            make.height.equalTo(@(total)).offset(10);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.bubbleView.mas_top).offset(5);
        }];
        
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        }];
        
        [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.statusLabel.mas_left);
            make.right.equalTo(self.statusLabel.mas_right);
            make.top.equalTo(self.statusLabel.mas_bottom).offset(5);
        }];
        
        [self.likesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.statusLabel.mas_right);
            make.right.equalTo(self.statusLabel.mas_right);
            make.top.equalTo(self.statusLabel.mas_bottom).offset(5);
            //            make.bottom.equalTo(self.bubbleView.mas_bottom).offset(15);
        }];
        
        [self.zipcodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.statusLabel.mas_left);
            make.right.equalTo(self.statusLabel.mas_right);
            make.top.equalTo(self.locationLabel.mas_bottom).offset(3);
            //            make.bottom.equalTo(self.bubbleView.mas_bottom).offset(15);
        }];
        
    }
}


-(void)updateLikes{
    UIImage *likeIcon;
    if(![self checkIfUserLiked]){
        likeIcon = [UIImage imageNamed:@"notliked.png"];
    } else {
        likeIcon = [UIImage imageNamed:@"liked.png"];
    }
    NSString *likeCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.assocs.count];
    [self.likesBtn setTitle:likeCount forState:UIControlStateNormal];
    [self.likesBtn setImage:likeIcon forState:UIControlStateNormal];
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
    [query whereKey:@"likedPost" equalTo:self.post];
    if(currentUser) [query whereKey:@"user" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *assocs, NSError *error) {
        if (assocs != nil) {
            self.userLiked = assocs;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)likeTapped:(id)sender {
    if([self checkIfUserLiked]){
        [self removeLikeAssoc];
    } else {
        [self createLikeAssoc];
    }
}

- (IBAction)statusDoubleTap:(id)sender {
    if([self checkIfUserLiked]){
        [self removeLikeAssoc];
    } else {
        [self createLikeAssoc];
    }
    [self loadLikeAnim];
}

- (IBAction)imageDoubleTap:(id)sender {
    if([self checkIfUserLiked]){
        [self removeLikeAssoc];
    } else {
        [self createLikeAssoc];
    }
    [self loadLikeAnim];
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
            [self queryLikes];
        } else {
            NSLog(@"Problem saving assoc: %@", error.localizedDescription);
        }
    }];
}

- (void)removeLikeAssoc{
    Assoc *usersLike = [self usersLike];
    [usersLike deleteInBackground];
    [self removeLikeCount];
    [self queryLikes];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
