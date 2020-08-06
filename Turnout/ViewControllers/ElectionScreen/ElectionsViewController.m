//
//  ElectionsViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ElectionsViewController.h"
#import "ElectionDetailController.h"
#import "VoterInfoCell.h"
#import "GoogleCivicAPI.h"

@interface ElectionsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *elections;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ElectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchElections];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchElections) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchElections{
    [[GoogleCivicAPI shared]fetchElections:^(NSArray *elections, NSError *error){
        if(elections)
            self.elections = elections;
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                  });
        NSMutableArray *bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
        for(NSDictionary *content in bookmarks){
            NSLog(@"bookmark = %@", content);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.elections.count;
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
    NSMutableDictionary *election = self.elections[indexPath.row];
    cell.infoCell = election;
    cell.adminLabel.text = [NSString stringWithFormat:@"Election Date: %@", election[@"electionDay"]];
    cell.titleLabel.text = election[@"name"];
    [cell createShadows];
    [cell checkBookmark];
    [cell loadBookmarks];
    return cell;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UITableViewCell *tappedCell = sender;
     NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
     NSDictionary *election = self.elections[indexPath.row];
     ElectionDetailController *detailController = [segue destinationViewController];
     detailController.election = election;
 }

@end
