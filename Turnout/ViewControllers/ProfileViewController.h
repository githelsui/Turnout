//
//  ProfileViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//
#import "ProfileTableView.h"
#import "GSKExampleData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : ProfileTableView

@property (nonatomic, readonly) GSKExampleData *data;

- (instancetype)initWithData:(GSKExampleData *)data;

@end

NS_ASSUME_NONNULL_END
