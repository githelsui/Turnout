//
//  OnboardViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "OnboardViewController.h"
#import "Zipcode.h"

@interface OnboardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMsg;
@property (weak, nonatomic) IBOutlet UILabel *instrucLabel;

@end

@implementation OnboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = PFUser.currentUser;
    [self presentUI];
}

- (void)presentUI{
    self.welcomeMsg.text = [NSString stringWithFormat:@"Welcome, %@", self.currentUser.username];
    self.instrucLabel.text = @"Enter your zipcode so Turnout can refine your results.";
}

- (IBAction)continueTapped:(id)sender {
    NSString *zipcode = self.zipcodeField.text;
    if(zipcode.length > 0){
        Zipcode *zip = [Zipcode new];
        zip.zipcode = zipcode;
        self.currentUser[@"zipcode"] = zip;
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                NSLog(@"The message was saved!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
            } else {
                NSLog(@"Problem saving message: %@", error.localizedDescription);
            }
        }];
    } else {
        [self showAlert:@"Cannot Enter Empty Zipcode" subtitle:@""];
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
