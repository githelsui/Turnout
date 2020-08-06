//
//  VoteInfoViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/28/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VoteInfoViewController.h"
#import "GoogleCivicAPI.h"
#import "VoteWebView.h"
#import "VoterInfoCell.h"
#import <Parse/Parse.h>
#import "Zipcode.h"

@interface VoteInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *infoCells;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation VoteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getZipcode];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchVoterInfo];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchVoterInfo) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchVoterInfo{
    [[GoogleCivicAPI shared] fetchVoterInfo:self.zipcode completion:^(NSArray *info, NSError *error){
        if(info){
            self.infoCells = [info mutableCopy];
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

- (void)getZipcode{
    PFUser *currentUser = PFUser.currentUser;
    Zipcode *zip = currentUser[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            self.zipcode = zipcode[@"zipcode"];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoterInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoterInfoCell"];
    if (cell == nil) {
        cell = [[VoterInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoterInfoCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    NSMutableDictionary *info = self.infoCells[indexPath.row];
    cell.infoCell = info;
    [cell setCell];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VoteInfoSegue"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        NSMutableDictionary *info = self.infoCells[indexPath.row];
        NSString *url = info[@"url"];
        VoteWebView *webView = [segue destinationViewController];
        webView.linkURL = url;
        NSLog(@"Segue");
    }
}


@end
