//
//  ElectionDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ElectionDetailController.h"
#import "ElectionDetailCell.h"
#import "GoogleCivicAPI.h"
#import "Zipcode.h"
#import <Parse/PFImageView.h>

@interface ElectionDetailController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *details;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ElectionDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setNavigationBar];
    [self fetchElectionDetail];
    self.refreshControl = [[UIRefreshControl alloc] init];
       [self.refreshControl addTarget:self action:@selector(fetchElectionDetail) forControlEvents:UIControlEventValueChanged];
       [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = self.election[@"name"];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)fetchElectionDetail{
    PFUser *currentUser = PFUser.currentUser;
    Zipcode *zip = currentUser[@"zipcode"];
    NSString *electionId = self.election[@"id"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *zipStr = zipcode[@"zipcode"];
            [[GoogleCivicAPI shared] fetchElectionDetails:zipStr election:electionId completion:^(NSMutableDictionary *info, NSError *error){
                if(info){
                    NSArray *arr = info[@"details"];
                    self.details = arr;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                        NSMutableArray *bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
                        for(NSDictionary *content in bookmarks){
                            NSLog(@"bookmark = %@", content);
                        }
                    });
                }
            }];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.details.count;
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
    NSMutableDictionary *detail = self.details[indexPath.row];
    NSLog(@"type of data: %@ ", detail);
    cell.content = detail;
    [cell setCell:detail[@"type"]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
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
