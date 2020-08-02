//
//  ProfileStickyHeader.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileStickyHeader
- (void)refreshFeed:(NSInteger)index;
@end

@interface ProfileStickyHeader : GSKStretchyHeaderView
@property (nonatomic, weak) id<ProfileStickyHeader> delegate;
@property (nonatomic, strong) NSString *zipcodeStr;
@property (nonatomic, strong) NSString *locationStr;
@property (nonatomic, strong) NSString *usernameStr;
@property (nonatomic) UILabel *title;
@property (nonatomic) UILabel *username;
@property (nonatomic) UILabel *location;
@property (nonatomic) UILabel *zipcode;
@property (nonatomic) UISegmentedControl *tabs;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (void)setupViews;
@end

NS_ASSUME_NONNULL_END
