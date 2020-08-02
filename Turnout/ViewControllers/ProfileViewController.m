//
//  ProfileViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileViewController.h"
#import "UINavigationController+Transparency.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ProfileViewController

- (instancetype)initWithData:(GSKExampleData *)data {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _data = data;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.data.navigationBarVisible) {
        [self.navigationController gsk_setNavigationBarTransparent:YES animated:NO];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

- (GSKStretchyHeaderView *)loadStretchyHeaderView {
    GSKStretchyHeaderView *headerView;

    if (self.data.headerViewClass) {
        headerView = [[self.data.headerViewClass alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.data.headerViewInitialHeight)];
    } else if (self.data.nibName) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:self.data.nibName
                                                          owner:self
                                                        options:nil];
        headerView = nibViews.firstObject;
    } else {
        [NSException raise:@"Can't initialise header view"
                    format:@"You must provide a header view in GSKExampleData instances"];
    }

    return headerView;
}

@end

NS_ASSUME_NONNULL_END

