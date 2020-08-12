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
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ElectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchElections];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchElections) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)setUpFooter{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];
    loadView.alpha = 0;
    self.tableView.tableFooterView = loadView;
    [UIView animateWithDuration:4 animations:^{
        loadView.alpha = 1;
    }];
}

- (void)setNavigationBar{
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage
    imageNamed:@"yourImageName"] style:UIBarButtonItemStylePlain target:self
                                                                 action:@selector(goBack:)];
    myBackButton.tintColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem = myBackButton;
}

- (void)goBack:(id)sender {
   [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)startTimer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
        self.timer = [NSTimer timerWithTimeInterval:1
                                             target:self
                                           selector:@selector(reloadTable)
                                           userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
        });
    });
}

- (void)reloadTable{
    [self.tableView reloadData];
}

- (void)fetchElections{
    [[GoogleCivicAPI shared]fetchElections:^(NSArray *elections, NSError *error){
        if(elections)
            self.elections = elections;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self setUpFooter];
            [self startTimer];
        });
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
