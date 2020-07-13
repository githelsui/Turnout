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
#import <Parse/Parse.h>
#import "User.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) FBSDKProfile *fbsdkProfile;
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
    CGPoint point;
    point.x = self.view.center.x;
    point.y = self.signUpButton.layer.frame.size.height + self.signUpButton.layer.position.y + 10;
    loginButton.center = point;
    int btnLength = self.usernameField.layer.frame.size.width;
    CGRect rect = CGRectMake(0, 0,  btnLength,  40);
    loginButton.bounds = rect;
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
        //        [self getFBUser];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    }
}

- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSLog(@"%s", "User logged in");
}

- (IBAction)signUpTapped:(id)sender {
    BOOL emptyString = [self.usernameField.text isEqual:@""];
    if(emptyString){
        [self showAlert:@"Username cannot be empty." subtitle:@""];
    } else {
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        [self saveParseUser:username password:password];
    }
}

- (IBAction)loginTapped:(id)sender {
    BOOL emptyString = [self.usernameField.text isEqual:@""];
    if(emptyString){
        [self showAlert:@"Username cannot be empty." subtitle:@""];
    } else {
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        [self logExistingAcc:username password:password];
    }
}

- (void)saveParseUser: (NSString *)name password:(NSString *)password{
    PFUser *newUser = [PFUser user];
    newUser.username = name;
    newUser.password = password;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self logExistingAcc:name password:password];
        } else {
            NSLog(@"User registered successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        }
    }];
}

- (void)logExistingAcc: (NSString *)username password:(NSString *)password{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self showAlert:error.localizedDescription subtitle:@""];
        } else {
            NSLog(@"User logged in successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        }
    }];
}

- (void)showAlert:(NSString *)title subtitle:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

//- (void)getFBUser{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [FBSDKProfile loadCurrentProfileWithCompletion:
//         ^(FBSDKProfile *profile, NSError *error) {
//            if (profile) {
//                self.fbsdkProfile = profile;
//                NSString *name = profile.firstName;
//                NSString *pass = profile.userID;
//                [self saveParseUser:name password:pass];
//            }
//        }];
//    });
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
