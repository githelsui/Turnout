//
//  ProfileTestController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileTestController.h"
#import "SettingsViewController.h"
#import "ProfileStickyHeader.h"
#import "ElectionDetailController.h"
#import "PostDetailController.h"
#import "CandidateDetailController.h"
#import "StateElectionDetail.h"
#import "PropViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "VoteWebView.h"
#import "BookmarkedCell.h"
#import "Assoc.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Zipcode.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ProfileTestController () <SettingsViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ProfileStickyHeader *header;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSArray *bookmarks;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) NSInteger tableType;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ProfileTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self setNavigationBar];
    CGRect rect = CGRectMake(0, 0,  self.tableView.frame.size.width,  200);
    self.header = [[ProfileStickyHeader alloc] initWithFrame:rect];
    [self setHeader];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Profile";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    lblTitle.font = [UIFont systemFontOfSize:28 weight:UIFontWeightThin];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)setHeader{
    [self getCurrentUserInfo];
    [self.header setupViews];
    [self.tableView addSubview:self.header];
    self.header.tableView = self.tableView;
    [self fetchMyStatuses];
    [self checkSegmentedControl];
}

- (void)startTimer{
    if(self.currentUser){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
            self.timer = [NSTimer timerWithTimeInterval:1
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
}

- (void)getCurrentUserInfo{
    self.currentUser = PFUser.currentUser;
    self.header.usernameStr = self.currentUser[@"username"];
    Zipcode *zip = self.currentUser[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            self.location = [NSString stringWithFormat:@"%@, %@", zipcode[@"city"], zipcode[@"shortState"]];
            self.zipcode = zipcode[@"zipcode"];
            self.header.locationStr = self.location;
            self.header.zipcodeStr = self.zipcode;
        }
    }];
}

- (void)initTableView{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 148;
    self.tableView.dragInteractionEnabled = YES;
    self.tableView.allowsSelection = YES;
    self.tableView.tableFooterView = [UIView new];
    [self setUpFooter];
}

- (void)setUpFooter{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    loadView.alpha = 0;
    self.tableView.tableFooterView = loadView;
    [UIView animateWithDuration:4 animations:^{
        loadView.alpha = 1;
    }];
}

- (void)checkSegmentedControl{
    [self.header.tabs addTarget:self action:@selector(tableChanged:) forControlEvents: UIControlEventValueChanged];
}

- (void)tableChanged:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    if(index == 0){
        self.tableType = 0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        [self fetchMyStatuses];
    } else if(index == 1){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableType = 1;
        [self fetchLikedStatuses];
    } else if(index == 2){
        self.tableView.rowHeight = 146;
        self.tableType = 2;
        [self fetchBookmarks];
    }
}

- (void)refreshTable{
    if(self.tableType == 0){
        self.tableType = 0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        [self fetchMyStatuses];
    } else if(self.tableType == 1){
        self.tableType = 1;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        [self fetchLikedStatuses];
    } else if(self.tableType == 2){
        self.tableView.rowHeight = 146;
        self.tableType = 2;
        [self fetchBookmarks];
    }
}

- (void)fetchBookmarks{
    NSArray *temp = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    self.bookmarks = [[temp reverseObjectEnumerator] allObjects];
    NSLog(@"THE bookmarks");
    for(NSData *data in self.bookmarks){
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"bookmark = %@", bookmarkDict);
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.refreshControl endRefreshing];
    [self startTimer];
}

- (void)fetchMyStatuses{
    NSLog(@"switched to statuses");
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" equalTo:self.currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results){
            self.posts = results;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self startTimer];
            });
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)fetchLikedStatuses{
    NSLog(@"switched to likes");
    PFQuery *query = [PFQuery queryWithClassName:@"Assoc"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"typeId" equalTo:@"Like"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query includeKey:@"likedPost"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *assocs, NSError *error) {
        if (assocs != nil) {
            NSMutableArray *posts = [NSMutableArray array];
            for(Assoc *assoc in assocs){
                Post *post = assoc[@"likedPost"];
                [posts addObject:post];
            }
            self.likes = [posts copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self startTimer];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger *rows;
    if(self.tableType == 0){
        rows = self.posts.count;
    } else if(self.tableType == 1){
        rows = self.likes.count;
    } else if(self.tableType == 2){
        rows = self.bookmarks.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.tableType == 0 || self.tableType == 1){
        PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
        
        if (cell == nil) {
            cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
        }
        
        BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
        if (!hasContentView) {
            [cell addSubview:cell.contentView];
        }
        Post *post;
        if(self.tableType == 0 ) post = self.posts[indexPath.row];
        else post = self.likes[indexPath.row];
        cell.post = post;
        [cell setCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        BookmarkedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkedCell"];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"BookmarkedCell" bundle:nil] forCellReuseIdentifier:@"BookmarkedCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkedCell"];
        }
        BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
        if (!hasContentView) {
            [cell addSubview:cell.contentView];
        }
        NSData *bookmarkInfo = self.bookmarks[indexPath.row];
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmarkInfo];
        cell.bookmarkInfo = bookmarkDict;
        [cell setCell];
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.tableType == 2){
        NSData *bookmarkInfo = self.bookmarks[indexPath.row];
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmarkInfo];
        [self segueToInfoScreen:bookmarkDict];
    }
}

- (void)segueToInfoScreen:(NSDictionary *)bookmark{
    NSDictionary *data = bookmark[@"data"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NSString *key = bookmark[@"type"];
    if([key isEqualToString:@"voterInfo"]){
        VoteWebView *vc = [storyboard instantiateViewControllerWithIdentifier:@"VoteWebView"];
        NSString *url = data[@"url"];
        vc.linkURL = url;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if([key isEqualToString:@"nationalElection"]){
        ElectionDetailController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ElectionDetailController"];
        vc.election = data;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if([key isEqualToString:@"candidateInfo"]){
        CandidateDetailController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"CandidateDetailController"];
        detailController.candidate = data;
        [self presentViewController:detailController animated:YES completion:nil];
    }
    else if([key isEqualToString:@"propInfo"]){
        PropViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"PropViewController"];
        detailController.prop = data;
        [self presentViewController:detailController animated:YES completion:nil];
    }
    else if([key isEqualToString:@"stateElection"]){
        StateElectionDetail *detailController = [storyboard instantiateViewControllerWithIdentifier:@"StateElectionDetail"];
        detailController.election = data;
        [self presentViewController:detailController animated:YES completion:nil];
    }
}

- (void)updateZipcode{
    [self getCurrentUserInfo];
    [self.header updateHeader];
    [self refreshTable];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    if([segue.identifier isEqualToString:@"SettingsSegue"]){
        [self.timer invalidate];
        self.timer = nil;
        SettingsViewController *settingControl = [segue destinationViewController];
        settingControl.delegate = self;
    }
    if (self.tableType !=2 && [segue.identifier isEqualToString:@"PostDetailSegue"]){
        PostDetailController *detailController = [segue destinationViewController];
        if(self.tableType == 0){
            Post *post = self.posts[indexPath.row];
            detailController.post = post;
        } else if(self.tableType == 1){
            Post *post = self.likes[indexPath.row];
            detailController.post = post;
        }
    }
}


@end
