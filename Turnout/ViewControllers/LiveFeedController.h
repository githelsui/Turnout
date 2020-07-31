//
//  LiveFeedController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/PFImageView.h>
#import "RankAlgorithm.h"
#import "PostCell.h"
#import "Post.h"
#import "PostDetailController.h"
#import "ComposeViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveFeedController : UIViewController
@property (nonatomic, strong) PFUser *currentUser;
@end

NS_ASSUME_NONNULL_END
