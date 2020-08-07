//
//  SettingsViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "SettingsViewController.h"
#import <CCActivityHUD/CCActivityHUD.h>
#import <Parse/Parse.h>
#import "Zipcode.h"
#import "GeoNamesAPI.h"
#import "FCAlertView.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@property (nonatomic, strong)  NSArray *zipcodes;
@property (nonatomic, strong)  PFUser *currentUser;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = PFUser.currentUser;
    [self customizeActivityIndic];
    [self presentUI];
}

- (IBAction)saveTap:(id)sender {
    NSString *zipcode = self.zipcodeField.text;
    if(zipcode.length > 0){
        [self findExistingZip:zipcode];
    } else {
        [self showAlert:@"Enter Valid Zipcode" msg:@""];
    }
}

- (IBAction)cancelTap:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
}

- (void)presentUI{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.zipcodeField.leftView = paddingView;
    self.zipcodeField.leftViewMode = UITextFieldViewModeAlways;
    self.zipcodeField.layer.cornerRadius = 17;
    self.zipcodeField.rightView = paddingView;
    self.zipcodeField.leftViewMode = UITextFieldViewModeAlways;
    self.saveBtn.layer.cornerRadius = 17;
}

- (Zipcode *)zipcodeToSave:(NSString *)zipcode{
    for(Zipcode *zip in self.zipcodes){
        NSLog(@"zips: %@", zip);
        if(zip.zipcode == zipcode)
            return zip;
    }
    return nil;
}

- (void)findExistingZip:(NSString *)zipcode{
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcode"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [query findObjectsInBackgroundWithBlock:^(NSArray *zips, NSError *error) {
        if (zips.count > 0) {
            self.zipcodes = zips;
            [self saveZipInUser:self.zipcodes[0]];
        } else {
            [self fetchZipcode:zipcode];
        }
    }];
    [self.activityHUD dismiss];
}

- (void)fetchZipcode:(NSString *)zipcode{
    [[GeoNamesAPI shared] fetchZipcode:zipcode completion:^(NSArray *zipcodes, NSError *error){
        if(zipcodes.count > 0){
            NSDictionary *zip = zipcodes[0];
            [Zipcode createNewZip:zip withCompletion:^(BOOL succeeded, NSError * error){
                if(succeeded){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate updateZipcode];
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"SettingNotification"
                         object:self];
                        [self showAlert:@"New Zipcode Saved" msg:@""];
                        [self dismissViewControllerAnimated:true completion:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlert:@"Problem saving zipcode" msg:error.localizedDescription];
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Not a Valid US Zipcode" msg:@"Try Again"];
            });
        }
    }];
}

- (void)saveZipInUser:(Zipcode *)zip{
    self.currentUser[@"zipcode"] = zip;
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateZipcode];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"SettingNotification"
                 object:self];
                [self showAlert:@"New Zipcode Saved" msg:@""];
                [self dismissViewControllerAnimated:true completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Problem saving zipcode" msg:error.localizedDescription];
            });
        }
    }];
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.cornerRadius = 20;
    alert.colorScheme = alert.flatOrange;
    alert.detachButtons = YES;
    alert.titleFont = [UIFont systemFontOfSize:25 weight:UIFontWeightThin];
    alert.subtitleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    [alert showAlertInView:self
                 withTitle:title
              withSubtitle:msg
           withCustomImage:nil
       withDoneButtonTitle:@"OK"
                andButtons:nil];
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
