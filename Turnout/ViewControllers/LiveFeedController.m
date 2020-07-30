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

@interface LiveFeedController () <RankAlgorithmDelegate, PostCellDelegate, ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentLoc;
@property (weak, nonatomic) IBOutlet UILabel *currentZipcode;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *mutablePosts;
@property (nonatomic, strong) RankAlgorithm *rankAlgo;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property int skipIndex;
@end

@implementation LiveFeedController
NSTimeInterval lastClick;
NSIndexPath *lastIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.skipIndex = 0;
    [self initTableView];
    [self setUpFooter];
    self.rankAlgo = [[RankAlgorithm alloc]init];
    [self reloadFeed];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadFeed) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)initTableView{
    [self setUpHeader];
    self.mutablePosts =  [NSMutableArray array];
    self.tableView.allowsSelection = false;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setGestureRecogs];
}

- (void)setUpHeader{
    self.currentUser = PFUser.currentUser;
    Zipcode *zip = self.currentUser[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
           if(zipcode){
               NSString *location = [NSString stringWithFormat:@"%@, %@", zipcode[@"city"], zipcode[@"shortState"]];
               self.currentLoc.text = location;
               self.currentZipcode.text = zipcode[@"zipcode"];
           }
       }];
}

- (void)setUpFooter{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadView.alpha = 1;
    button.alpha = 1;
    [button setTitle:@"Load More" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    button.frame=CGRectMake(0, 0, self.view.bounds.size.width - 10, 50);
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightThin];
    loadView.center = CGPointMake(self.view.center.x, 0);
    button.center = CGPointMake(self.view.center.x, 30);
    button.layer.cornerRadius = 20;
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    [loadView addSubview:button];
    self.tableView.tableFooterView = loadView;
    [UIView animateWithDuration:4 animations:^{
        loadView.alpha = 1;
        button.alpha = 1;
    }];
}

//- (void)startTimer{
//    if(self.currentUser){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
//                       {
//            self.timer = [NSTimer timerWithTimeInterval:1
//                                                 target:self
//                                               selector:@selector(queryPostsWhenLoad)
//                                               userInfo:nil repeats:YES];
//            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//            dispatch_async(dispatch_get_main_queue(), ^(void)
//                           {
//            });
//        });
//    }
//}

//- (void)reloadData{
//    [self.tableView reloadData];
//    NSLog(@"%s", "timer going off");
//}

- (void)reloadFeed{
    [self.rankAlgo queryPosts:0 completion:^(NSArray *posts, NSError *error){
        if(posts){
            self.posts = posts;
            self.mutablePosts = [posts mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self setUpFooter];
            });
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)fetchMorePosts{
    self.skipIndex += 2;
    [self.rankAlgo queryPosts:self.skipIndex completion:^(NSArray *posts, NSError *error){
        if(posts){
            self.posts = posts;
            self.mutablePosts = [posts mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self setUpFooter];
            });
        }
    }];
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
    cell.delegate = self;
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
        Post *post = self.mutablePosts[indexPath.row];
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

- (void)loadMore{
    NSLog(@"load more posts");
    [self fetchMorePosts];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSegue"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.mutablePosts[indexPath.row];
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
//    [self startTimer];
}

- (void)postToTopFeed:(Post *)post {
    [self.mutablePosts insertObject:post atIndex:0];
    NSLog(@"mutable posts = %@", self.mutablePosts);
//    [self startTimer];
}

@end
