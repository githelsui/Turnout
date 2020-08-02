//
//  ProfileStickyHeader.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileStickyHeader : GSKStretchyHeaderView

@property (nonatomic) UILabel *title;
@property (nonatomic) UILabel *username;
@property (nonatomic) UILabel *location;
@property (nonatomic) UILabel *zipcode;

@end

NS_ASSUME_NONNULL_END
