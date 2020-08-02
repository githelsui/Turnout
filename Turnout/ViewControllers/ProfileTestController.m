//
//  ProfileTestController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileTestController.h"
#import "ProfileStickyHeader.h"
#import "Post.h"
#import "PostCell.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Zipcode.h"

@interface ProfileTestController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ProfileStickyHeader *header;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic) int tableType;

@end

@implementation ProfileTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    CGRect rect = CGRectMake(0, 0,  self.tableView.frame.size.width,  200);
    self.header = [[ProfileStickyHeader alloc] initWithFrame:rect];
    [self getCurrentUserInfo];
    [self.header setupViews];
    [self.tableView addSubview:self.header];
//    header.delegate = self;
    self.header.tableView = self.tableView;
    [self fetchMyStatuses];
    [self checkSegmentedControl];
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
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.header setupViews];
//                [self.tableView addSubview:self.header];
            });
        }
    }];
}

- (void)initTableView{
    [self.tableView registerClass:PostCell.class forCellReuseIdentifier:@"PostCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       self.tableView.rowHeight = UITableViewAutomaticDimension;
       self.tableView.dataSource = self;
       self.tableView.delegate = self;
}

- (void)checkSegmentedControl{
    [self.header.tabs addTarget:self action:@selector(tableChanged:) forControlEvents: UIControlEventValueChanged];
}

- (void)tableChanged:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    if(index == 0){
        [self fetchMyStatuses];
    } else {
        [self fetchLikedStatuses];
    }
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
                      });
        }
    }];
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
               self.likes = assocs;
               dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                   });
           } else {
               NSLog(@"%@", error.localizedDescription);
           }
       }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.posts.count;
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
    
    if(self.tableType == 0){
        Post *post = self.posts[indexPath.row];
        cell.post = post;
        [cell setCell];
    } else {
        Post *post = self.likes[indexPath.row];
        cell.post = post;
        [cell setCell];
    }
    
    return cell;
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
