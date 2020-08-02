//
//  ProfileTestController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileTestController.h"
#import "ProfileStickyHeader.h"

@interface ProfileTestController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) GSKStretchyHeaderView *stretchyHeader;

@end

@implementation ProfileTestController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CGSize headerSize = CGSizeMake(self.tableView.frame.size.width, 200);
    CGRect rect = CGRectMake(0, 0,  self.tableView.frame.size.width,  100);
    ProfileStickyHeader *header = [[ProfileStickyHeader alloc] initWithFrame:rect];
    [self.tableView addSubview:header];
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
