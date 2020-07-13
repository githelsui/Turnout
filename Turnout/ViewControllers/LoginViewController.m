//
//  LoginViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LiveFeedController.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"%s", "user loggedon");
    }
    [self setFBLogin];
}

- (void)setFBLogin{
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    loginButton.permissions = @[@"public_profile", @"email"];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
  if (error) {
    NSLog(@"%@", error.localizedDescription);
  }
  if (result.isCancelled) {
    NSLog(@"User cancelled the login action.");
  } else if (result.declinedPermissions.count > 0) {
    NSLog(@"User has declined permission.");
  } else {
      NSString * storyboardName = @"Main";
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
      UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
      [self presentViewController:vc animated:YES completion:nil];
  }
}



- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    
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
