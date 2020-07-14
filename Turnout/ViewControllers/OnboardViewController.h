//
//  OnboardViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface OnboardViewController : UIViewController
@property (nonatomic, strong) PFUser *currentUser;
@end

NS_ASSUME_NONNULL_END
