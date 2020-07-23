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
@property (nonatomic, strong)  NSArray *zipcodes;

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
        [self findExistingZip:zipcode];
        Zipcode *zip = [self zipcodeToSave:zipcode];
        if(zip) [self saveZipInUser:zip];
        else [self zipcodeToCreate:zipcode];
    } else {
        [self showAlert:@"Cannot Enter Empty Zipcode" subtitle:@""];
    }
}

- (Zipcode *)zipcodeToSave:(NSString *)zipcode{
    for(Zipcode *zip in self.zipcodes){
        NSLog(@"zips: %@", zip);
        if(zip.zipcode == zipcode)
            return zip;
    }
    return nil;
}

- (void)zipcodeToCreate:(NSString *)zipcode{
    [Zipcode saveNewZipcode:zipcode withCompletion:^(BOOL succeeded, NSError *error){
        if(error){
            [self showAlert:@"Not a Valid US Zipcode" subtitle:@"Try Again"];
        } else {
            [self segueToTurnout];
        }
    }];
}

- (void)saveZipInUser:(Zipcode *)zip{
    self.currentUser[@"zipcode"] = zip;
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            [self segueToTurnout];
        } else {
            [self showAlert:@"Problem saving zipcode" subtitle:error.localizedDescription];
        }
    }];
}

- (void)findExistingZip:(NSString *)zipcode{
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcode"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [query findObjectsInBackgroundWithBlock:^(NSArray *zips, NSError *error) {
        if (zips != nil) {
            self.zipcodes = zips;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)segueToTurnout{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
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
