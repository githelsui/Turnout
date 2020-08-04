//
//  OnboardViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "OnboardViewController.h"
#import "Zipcode.h"
#import "GeoNamesAPI.h"
#import <CCActivityHUD/CCActivityHUD.h>

@interface OnboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeMsg;
@property (weak, nonatomic) IBOutlet UILabel *instrucLabel;
@property (nonatomic, strong)  NSArray *zipcodes;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@end

@implementation OnboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = PFUser.currentUser;
    [self presentUI];
    [self startAnimation];
    [self customizeActivityIndic];
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
}

- (void)presentUI{
    self.welcomeMsg.alpha = 0;
    self.instrucLabel.alpha = 0;
    self.continueBtn.alpha = 0;
    self.zipcodeField.alpha = 0;
    self.titleLabel.alpha = 0;
    self.welcomeMsg.text = [NSString stringWithFormat:@"Welcome, %@", self.currentUser.username];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.zipcodeField.leftView = paddingView;
    self.zipcodeField.leftViewMode = UITextFieldViewModeAlways;
    self.zipcodeField.layer.cornerRadius = 17;
    self.continueBtn.layer.cornerRadius = 17;
}

- (void)startAnimation{
    CGPoint finalTitlePos = self.titleLabel.layer.position;
    CGFloat titleY = finalTitlePos.y;
    CGFloat startTitleY = titleY + 77;
    CGPoint startTitlePos = CGPointMake(finalTitlePos.x, startTitleY);
    self.titleLabel.layer.position = startTitlePos;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.titleLabel.layer.position = finalTitlePos;
        self.titleLabel.alpha = 1;
        self.welcomeMsg.alpha = 1;
        self.instrucLabel.alpha = 1;
        self.continueBtn.alpha = 1;
        self.zipcodeField.alpha = 1;
    } completion:^(BOOL finished) {}];
}

- (IBAction)continueTapped:(id)sender {
    NSString *zipcode = self.zipcodeField.text;
    if(zipcode.length > 0){
        [self findExistingZip:zipcode];
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

- (void)saveZipInUser:(Zipcode *)zip{
    self.currentUser[@"zipcode"] = zip;
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self segueToTurnout];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Problem saving zipcode" subtitle:error.localizedDescription];
            });
        }
    }];
}

- (void)findExistingZip:(NSString *)zipcode{
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcode"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [query findObjectsInBackgroundWithBlock:^(NSArray *zips, NSError *error) {
        [self.activityHUD dismiss];
        if (zips.count > 0) {
            self.zipcodes = zips;
            [self saveZipInUser:self.zipcodes[0]];
        } else {
            [self fetchZipcode:zipcode];
        }
    }];
}

- (void)fetchZipcode:(NSString *)zipcode{
    [[GeoNamesAPI shared] fetchZipcode:zipcode completion:^(NSArray *zipcodes, NSError *error){
        if(zipcodes.count > 0){
            NSDictionary *zip = zipcodes[0];
            [Zipcode createNewZip:zip withCompletion:^(BOOL succeeded, NSError * error){
                if(succeeded){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self segueToTurnout];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlert:@"Problem saving zipcode" subtitle:error.localizedDescription];
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Not a Valid US Zipcode" subtitle:@"Try Again"];
            });
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
