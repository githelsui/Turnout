//
//  PropViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PropViewController.h"
#import "ProPublicaAPI.h"

@interface PropViewController ()
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *longTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *chamberLabel;
@property (weak, nonatomic) IBOutlet UILabel *billLabel;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabel;
@property (weak, nonatomic) IBOutlet UILabel *committeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *textsBtn;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (nonatomic, strong) NSString *propId;
@property (nonatomic, strong) NSDictionary *propInfo;
@property (nonatomic, strong) NSString *textsURL;
@property (nonatomic, strong) NSString *actionsURL;
@end

@implementation PropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBasicUI];
    [self setPropInfo];
    [self fetchPropDetails];
}

- (void)setBasicUI{
    self.mainView.clipsToBounds = true;
    self.mainView.layer.cornerRadius = 15;
    self.nameView.clipsToBounds = true;
    self.nameView.layer.cornerRadius = 15;
    self.generalView.clipsToBounds = true;
    self.generalView.layer.cornerRadius = 15;
    self.detailView.clipsToBounds = true;
    self.detailView.layer.cornerRadius = 15;
    self.textsBtn.layer.cornerRadius = 15;
    self.actionBtn.layer.cornerRadius = 15;
}

- (void)setPropInfo{
    self.propId = self.prop[@"bill_slug"];
}

- (void)setPropFetchedInfo{
    self.nameLabel.text = self.propInfo[@"short_title"];
    self.longTitleLabel.text = self.propInfo[@"title"];
    NSString *summary = self.propInfo[@"summary_short"];
    if([summary isEqualToString:@""]) self.summaryLabel.text = @"No Summary Provided";
    else self.summaryLabel.text = summary;
    self.subjectLabel.text = self.propInfo[@"primary_subject"];
    self.chamberLabel.text = [self getChamber];
    self.billLabel.text = self.prop[@"bill_number"];
    self.sponsorLabel.text = self.propInfo[@"sponsor"];
    self.committeeLabel.text = self.propInfo[@"committees"];
    self.dateLabel.text = self.prop[@"legislative_day"];
    self.textsURL = self.propInfo[@"congressdotgov_url"];
    self.actionsURL = self.propInfo[@"govtrack_url"];
}

- (NSString *)getChamber{
    NSString *chamber = self.propInfo[@"chamber"];
    if([chamber isEqualToString:@"House"]) return @"House of Representatives";
    else return chamber;
}

- (void)fetchPropDetails{
    [[ProPublicaAPI shared]fetchBillInfo:self.propId completion:^(NSArray *details, NSError *error){
        if(details){
            self.propInfo = details[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPropFetchedInfo];
            });
        }
    }];
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
