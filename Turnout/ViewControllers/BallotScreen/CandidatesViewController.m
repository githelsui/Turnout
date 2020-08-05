//
//  CandidatesViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CandidatesViewController.h"
#import "OpenFECAPI.h"
#import "CandidateCell.h"
#import <CCActivityHUD/CCActivityHUD.h>
#import "CandidateDetailController.h"
#import <Parse/Parse.h>
#import "Zipcode.h"

@interface CandidatesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSString *currentState;

@end

@implementation CandidatesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getCurrentUserInfo];
    [self customizeActivityIndic];
    [self fetchCandidates];
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
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


- (void)fetchCandidates{
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [[OpenFECAPI shared] fetchCandidates:self.currentState completion:^(NSArray *candidates, NSError *error){
        if(candidates){
            self.candidates = candidates;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityHUD dismiss];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.candidates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CandidateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CandidateCell"];
    if (cell == nil) {
        cell = [[CandidateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CandidateCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    NSMutableDictionary *candidate = self.candidates[indexPath.row];
    cell.candidate = candidate;
    [cell setCell];
    cell.alpha = 0;
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *candidate = self.candidates[indexPath.row];
    CandidateDetailController *detailController = [segue destinationViewController];
    detailController.candidate = candidate;
}

@end