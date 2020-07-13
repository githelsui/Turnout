//
//  LiveFeedController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "LiveFeedController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <Parse/Parse.h>

@interface LiveFeedController ()

@end

@implementation LiveFeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)logoutTapped:(id)sender {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    sceneDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {}];
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
