//
//  ProfileStickyHeader.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileStickyHeader.h"
#import "UIView+GSKLayoutHelper.h"
#import <GSKStretchyHeaderView/GSKGeometry.h>
#import <Masonry/Masonry.h>

@interface ProfileStickyHeader ()

@property (nonatomic) UIImageView *backgroundImageView;

@end

@implementation ProfileStickyHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumContentHeight = 64;
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    }
    return self;
}

- (void)setupViews {
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flipped_color"]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.backgroundImageView];
    
    self.zipcode = [[UILabel alloc] init];
    self.zipcode.textColor = [UIColor whiteColor];
    self.zipcode.text = self.zipcodeStr;
    self.zipcode.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
    [self.contentView addSubview:self.zipcode];
    
    self.username = [[UILabel alloc] init];
    self.username.textColor = [UIColor whiteColor];
    self.username.text = self.usernameStr;
    self.username.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
    [self.contentView addSubview:self.username];
    
    self.location = [[UILabel alloc] init];
    self.location.textColor = [UIColor whiteColor];
    self.location.text = self.locationStr;
    self.location.font = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    [self.contentView addSubview:self.location];
    
    [self setupTabs];
    [self setupViewConstraints];
}

- (void)setupTabs {
    self.tabs = [[UISegmentedControl alloc] initWithItems:@[@"Status", @"Likes", @"Bookmarks"]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                [UIFont systemFontOfSize:15 weight:UIFontWeightThin], NSFontAttributeName,
                                nil];
    
    [self.tabs setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor systemRedColor] forKey:NSForegroundColorAttributeName];
    [self.tabs setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    self.tabs.selectedSegmentIndex = 0;
    [self.contentView addSubview:self.tabs];
}

- (void)setupViewConstraints {
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(self.contentView.mas_height);
    }];

    [self.zipcode mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerX.equalTo(self.contentView.mas_centerX);
           make.top.equalTo(self.location.mas_bottom).offset(10);
       }];
    
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(-50);
    }];

    [self.location mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.username.mas_bottom).offset(10);
    }];
    
    [self.tabs mas_makeConstraints:^(MASConstraintMaker *make) {
          make.bottom.equalTo(@(-15));
          make.left.equalTo(@(15));
          make.right.equalTo(@(-15));
      }];

}

- (void)didChangeStretchFactor:(CGFloat)stretchFactor {
    CGFloat alpha = 1;
    CGFloat blurAlpha = 1;
    if (stretchFactor > 1) {
        alpha = CGFloatTranslateRange(stretchFactor, 1, 1.12, 1, 0);
        blurAlpha = alpha;
    } else if (stretchFactor < 0.8) {
        alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1);
    }

    alpha = MAX(0, alpha);
    self.title.alpha = alpha;
    self.username.alpha = alpha;
    self.location.alpha = alpha;
    self.zipcode.alpha = alpha;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
