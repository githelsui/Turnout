//
//  PropsViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PropsViewController.h"
#import "ProPublicaAPI.h"
#import "VoterInfoCell.h"
#import "PropViewController.h"

@interface PropsViewController () <PropDetailSegue, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *props;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation PropsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchProps];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchProps) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
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

- (void)setUpFooter{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];
    loadView.alpha = 0;
    self.tableView.tableFooterView = loadView;
    [UIView animateWithDuration:4 animations:^{
        loadView.alpha = 1;
    }];
}

- (void)fetchProps{
    [[ProPublicaAPI shared] fetchHouseBills:^(NSArray *propositions, NSError *error){
        if(propositions){
            self.props = propositions;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self startTimer];
                [self setUpFooter];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.props.count;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableDictionary *prop = self.props[indexPath.row];
    cell.infoCell = prop;
    [cell setPropCell];
    return cell;
}

- (void)refreshFeed{
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *prop = self.props[indexPath.row];
    PropViewController *detailController = [segue destinationViewController];
    detailController.prop = prop;
    detailController.delegate = self;
}


@end
