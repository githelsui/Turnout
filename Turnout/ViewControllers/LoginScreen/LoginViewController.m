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
#import "LiveFeedController.h"
#import "OnboardViewController.h"
#import "User.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIImageView *appImg;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) FBSDKProfile *fbsdkProfile;
@property (strong, nonatomic) FBSDKLoginButton *fbButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FBSDKAccessToken currentAccessToken]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    }
    [self setUI];
}

- (void)setUI{
    [self setAnimation];
    self.usernameField.alpha = 0;
    self.passwordField.alpha = 0;
    self.loginBtn.alpha = 0;
    self.signUpButton.alpha = 0;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 15, 0)];
    self.usernameField.leftView = paddingView;
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.rightView = paddingView;
    self.usernameField.rightViewMode = UITextFieldViewModeAlways;
    self.usernameField.layer.cornerRadius = 16;
    self.passwordField.layer.cornerRadius = 16;
    self.passwordField.leftView = padding;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.rightView = padding;
    self.passwordField.rightViewMode = UITextFieldViewModeAlways;
    self.signUpButton.layer.cornerRadius = 17;
    self.loginBtn.layer.cornerRadius = 17;
}

- (void)setAnimation{
    self.appImg.alpha = 0;
    self.titleLabel.alpha = 0;
    CGPoint finalTitlePos = self.titleLabel.layer.position;
    CGFloat titleY = finalTitlePos.y;
    CGPoint finalIconPos  = self.appImg.layer.position;
    CGFloat iconY = finalIconPos.y;
    CGFloat startTitleY = titleY + 200;
    CGFloat startIconY = iconY + 200;
    CGPoint startTitlePos = CGPointMake(finalTitlePos.x, startTitleY);
    CGPoint startIconPos = CGPointMake(finalIconPos.x, startIconY);
    self.titleLabel.layer.position = startTitlePos;
    self.appImg.layer.position = startIconPos;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.appImg.alpha = 1;
        self.titleLabel.alpha = 1;
        self.appImg.layer.position = finalIconPos;
        self.titleLabel.layer.position = finalTitlePos;
    } completion:^(BOOL finished) {
        if(finished){
            [self animateLoginUI];
        }
    }];
}

- (void)animateLoginUI{
    [self setFBLogin];
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.usernameField.alpha = 1;
        self.passwordField.alpha = 1;
        self.loginBtn.alpha = 1;
        self.signUpButton.alpha = 1;
        self.fbButton.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)setFBLogin{
    self.fbButton = [[FBSDKLoginButton alloc] init];
    self.fbButton.alpha = 0;
    self.fbButton.delegate = self;
    CGPoint point;
    point.x = self.view.center.x;
    point.y = self.signUpButton.layer.frame.size.height + self.signUpButton.layer.position.y + 17;
    self.fbButton.center = point;
    int btnLength = self.usernameField.layer.frame.size.width;
    CGRect rect = CGRectMake(0, 0,  btnLength,  45);
    self.fbButton.bounds = rect;
    self.fbButton.clipsToBounds = true;
    self.fbButton.layer.cornerRadius = 15;
    [self.view addSubview:self.fbButton];
    self.fbButton.permissions = @[@"public_profile", @"email"];
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
        [self getFBUser];
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
            self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"OnboardViewController"];
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

- (void)getFBUser{
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBSDKProfile loadCurrentProfileWithCompletion:
         ^(FBSDKProfile *profile, NSError *error) {
            if (profile) {
                self.fbsdkProfile = profile;
                NSString *name = profile.firstName;
                NSString *pass = profile.userID;
                [self saveParseUser:name password:pass];
            }
        }];
    });
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OnboardSegue"]){
        OnboardViewController *onboard = [segue destinationViewController];
        onboard.currentUser = PFUser.currentUser;
    } else if ([segue.identifier isEqualToString:@"TurnoutSegue"]) {
        LiveFeedController *live = [segue destinationViewController];
        live.currentUser = PFUser.currentUser;
    }
}


@end
