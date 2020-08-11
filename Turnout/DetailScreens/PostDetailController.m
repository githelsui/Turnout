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
#import "CommentViewController.h"
#import "Comment.h"

@interface PostDetailController () <CommentDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commentCount;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *secondCommLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCommLabel;
@property (weak, nonatomic) IBOutlet UIView *secondCommView;
@property (weak, nonatomic) IBOutlet UIView *firstCommView;
@property (weak, nonatomic) IBOutlet UIStackView *commentStack;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *commentSection;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
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
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (nonatomic, strong) NSArray *userLiked;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSMutableArray *recentComments;
@end

@implementation PostDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recentComments = [NSMutableArray array];
    [self setNavigationBar];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"goback" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self createShadows];
    [self setUI];
    [self updateLikes];
    [self queryRecentComments];
    [self setCommentCount];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queryLikes) userInfo:nil repeats:true];
}

- (void)setCommentCount{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"objectId" equalTo:self.post.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *post, NSError *error) {
          if (post) {
            NSString *count = [post[0][@"commentCount"] stringValue];
            [self.commentCount setTitle:count forState:UIControlStateNormal];
          }
      }];
}

- (void)prepComments{
    self.firstCommLabel.hidden = true;
    self.firstCommView.hidden = true;
    self.secondCommView.hidden = true;
    self.secondCommView.hidden = true;
}

- (void)noCommentsFound{
    self.firstCommLabel.hidden = true;
    self.firstCommView.hidden = true;
    self.secondCommView.hidden = true;
    self.secondCommView.hidden = true;
}

- (void)onlyOneComment{
//    [self.commentStack removeArrangedSubview:self.secondCommView];
    self.secondCommView.hidden = true;
    self.secondCommView.hidden = true;
    self.firstCommLabel.hidden = false;
    self.firstCommView.hidden = false;
}

- (void)queryRecentComments{
    [self.recentComments removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"post" equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments.count > 0) {
            self.comments = comments;
            if(comments.count == 1) [self onlyOneComment];
            [self saveRecentComments];
        } else {
            [self noCommentsFound];
        }
    }];
}

- (void)saveRecentComments{
    int index = 0;
    for(Comment *comment in self.comments){
        [self createComment:comment];
        if(index == 1) break;
        index++;
    }
}

- (void)createComment:(Comment *)comment{
    PFUser *commenter = comment.commenter;
    [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if(user){
            NSString *username = commenter[@"username"];
            NSString *strComment = [NSString stringWithFormat:@"%@: %@", username, comment.comment];
            [self.recentComments addObject:strComment];
            [self showComment];
        }
    }];
}

- (void)showComment{
    if(self.recentComments.count == 1){
        self.firstCommLabel.text = self.recentComments[0];
        self.firstCommView.hidden = false;
        self.firstCommLabel.hidden = false;
    } else if(self.recentComments.count == 2){
        self.secondCommLabel.text = self.recentComments[1];
        self.secondCommView.hidden = false;
        self.secondCommLabel.hidden = false;
    }
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
    [self loadImage];
    [self checkImageView];
    if(![FBSDKAccessToken currentAccessToken]){
        self.shareButton.alpha = 0;
    }
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Status";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    lblTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)createShadows{
    self.bubbleView.clipsToBounds = NO;
    self.bubbleView.layer.cornerRadius = 15;
    self.commentSection.clipsToBounds = NO;
    self.commentSection.layer.cornerRadius = 15;
    self.commentBtn.layer.cornerRadius = 12;
    self.firstCommView.layer.cornerRadius = 12;
    self.secondCommView.layer.cornerRadius = 12;
    self.firstCommView.layer.borderColor = [UIColor grayColor].CGColor;
    self.firstCommView.layer.borderWidth = 0.5f;
    self.secondCommView.layer.borderColor = [UIColor grayColor].CGColor;
    self.secondCommView.layer.borderWidth = 0.5f;
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
        [self.stackView removeArrangedSubview:self.attachedPhoto];
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

- (void)refreshComments{
    [self setCommentCount];
    [self queryRecentComments];
}

- (IBAction)commentTap:(id)sender {
    [self performSegueWithIdentifier: @"CommentSegue" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"CommentSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        CommentViewController *comments = (CommentViewController*)navigationController.topViewController;
        comments.post = self.post;
        comments.delegate = self;
    }
}

@end
