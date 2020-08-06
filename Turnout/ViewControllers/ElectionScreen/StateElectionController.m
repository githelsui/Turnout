//
//  StateElectionController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "StateElectionController.h"
#import "ElectionDetailCell.h"
#import "OpenFECAPI.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Zipcode.h"

@interface StateElectionController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSString *currentState;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *elections;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation StateElectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getCurrentUserInfo];
    [self fetchElections];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchElections) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)getCurrentUserInfo{
    self.currentUser = PFUser.currentUser;
    Zipcode *zip = self.currentUser[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            self.currentState = zipcode[@"shortState"];
        }
    }];
}

- (void)fetchElections{
    [[OpenFECAPI shared] fetchStateElections:self.currentState completion:^(NSArray *elections, NSError *error){
        if(elections){
            self.elections = elections;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                NSMutableArray *bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
                for(NSDictionary *content in bookmarks){
                    NSLog(@"bookmark = %@", content);
                }
            });
        }
    }];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.elections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ElectionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ElectionDetailCell"];
    if (cell == nil) {
        cell = [[ElectionDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ElectionDetailCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    NSMutableDictionary *election = self.elections[indexPath.row];
    NSLog(@"type of data: %@ ", election);
    cell.content = election;
    [cell setStateElection];
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
