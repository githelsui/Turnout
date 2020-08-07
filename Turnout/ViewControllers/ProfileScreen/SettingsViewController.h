//
//  SettingsViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SettingsViewDelegate
- (void)updateZipcode;
@end

@interface SettingsViewController : UIViewController
@property (nonatomic, weak) id<SettingsViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
