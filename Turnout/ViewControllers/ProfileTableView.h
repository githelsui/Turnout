//
//  ProfileTableView.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>
#import "GSKExampleDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileTableView : UITableViewController

@property (nonatomic, readonly) GSKStretchyHeaderView *stretchyHeaderView;
@property (nonatomic, readonly) GSKExampleDataSource *dataSource;

- (GSKExampleDataSource *)loadDataSource;
- (GSKStretchyHeaderView *)loadStretchyHeaderView;

@end

NS_ASSUME_NONNULL_END
