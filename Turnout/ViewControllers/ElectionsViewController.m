//
//  ElectionsViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ElectionsViewController.h"
#import "VoterInfoCell.h"
#import "GoogleCivicAPI.h"

@interface ElectionsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *elections;
@end

@implementation ElectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchElections];
}

- (void)fetchElections{
    [[GoogleCivicAPI shared]fetchElections:^(NSArray *elections, NSError *error){
        if(elections)
            self.elections = elections;
            dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
    }];
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
    cell.bubbleView.layer.cornerRadius = 15;
    cell.addressLabel.alpha = 0;
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
