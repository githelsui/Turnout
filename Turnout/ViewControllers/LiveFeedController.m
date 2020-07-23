//
//  LiveFeedController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "LiveFeedController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <Parse/PFImageView.h>
#import "RankAlgorithm.h"
#import "PostCell.h"
#import "Post.h"
#import "PostDetailController.h"
#import "ComposeViewController.h"

@interface LiveFeedController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *mutablePosts;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation LiveFeedController
NSTimeInterval lastClick;
NSIndexPath *lastIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = false;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setGestureRecogs];
    [self fetchPosts];
    [self startTimer];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)startTimer{
    PFUser *currentUser = PFUser.currentUser;
    if(currentUser || [FBSDKAccessToken currentAccessToken]){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
            self.timer = [NSTimer timerWithTimeInterval:0.3
                                                 target:self
                                               selector:@selector(reloadData)
                                               userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
            });
        });
    }
}

- (void)reloadData{
    [self.tableView reloadData];
    NSLog(@"%s", "timer going off");
}

- (void)setGestureRecogs{
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.tableView addGestureRecognizer:singleTap];
}

- (void)fetchPosts{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query setLimit:20];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = posts;
            self.mutablePosts = [posts mutableCopy];
            //[[RankAlgorithm shared] queryPosts:posts];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (IBAction)logoutTapped:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    sceneDelegate.window.rootViewController = loginViewController;
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mutablePosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    Post *post = self.mutablePosts[indexPath.row];
    cell.post = post;
    [cell setCell];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(void)singleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"Single Tap");
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        Post *post = self.posts[indexPath.row];
        PostDetailController *detailController = [[PostDetailController alloc] init];
        detailController.post = post;
        [self performSegueWithIdentifier:@"DetailSegue" sender:cell];
    }
}

-(void)doubleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"Double Taps");
    
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint: point];
    PostCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell doubleTapped];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSegue"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[indexPath.row];
        NSLog(@"post being passed %@", post);
        PostDetailController *detailController = [segue destinationViewController];
        detailController.post = post;
    } else if ([segue.identifier isEqualToString:@"ComposeSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
}

- (void)refreshFeed{
    [self fetchPosts];
    [self.tableView reloadData];
}

- (void)postToTopFeed:(Post *)post {
    [self.mutablePosts insertObject:post atIndex:0];
    NSLog(@"mutable posts = %@", self.mutablePosts);
}

@end
