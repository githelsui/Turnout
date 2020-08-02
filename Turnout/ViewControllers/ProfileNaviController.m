//
//  ProfileNaviController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileNaviController.h"
#import "ProfileViewController.h"
#import "ProfileStickyHeader.h"
#import "GSKExampleData.h"

@interface ProfileNaviController ()

@property (nonatomic) BOOL hasAppearedFlag;

@end

@implementation ProfileNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasAppearedFlag = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.hasAppearedFlag) {
        GSKExampleData *data = [GSKExampleData dataWithTitle:@"Example title"
                                             headerViewClass:[ProfileStickyHeader class]];
        ProfileViewController *viewController = [[ProfileViewController alloc] initWithData:data];
        [self.navigationController pushViewController:viewController animated:YES];
        self.hasAppearedFlag = YES;
    }
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
