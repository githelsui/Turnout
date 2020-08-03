//
//  CandidateDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CandidateDetailController.h"
#import "OpenFECAPI.h"

@interface CandidateDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
@property (weak, nonatomic) IBOutlet UILabel *partyLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLabel;
@property (weak, nonatomic) IBOutlet UILabel *districtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backColor;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *locLabel;
@property (nonatomic, strong) NSString *candidateId;
@property (nonatomic, strong) NSDictionary *details;
@end

@implementation CandidateDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.candidateId = self.candidate[@"candidate_id"];
    [self setUI];
    [self setNavigationBar];
    [self fetchCandidateInfo];
}

- (void)setUI{
    self.backColor.alpha = 0.70;
    self.backColor.layer.cornerRadius = 15;
    self.nameView.layer.cornerRadius = 15;
    self.infoView.layer.cornerRadius = 15;
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Specific Candidate";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)setInfoDetails{
    NSString *name = self.details[@"name"];
    NSString *office = self.candidate[@"office"];
    NSString *party = self.candidate[@"party"];
    NSString *candidateType = self.candidate[@"candidateType"];
    NSString *state = self.details[@"address_state"];
    NSString *city = self.details[@"address_city"];
    NSString *loc = [NSString stringWithFormat:@"%@, %@", city, state];
    NSString *district = [NSString stringWithFormat:@"Election District: %@", self.details[@"district"]];
    self.nameLabel.text = name;
    self.officeLabel.text = office;
    self.partyLabel.text = party;
    self.candidateLabel.text = candidateType;
    self.locLabel.text = loc;
    self.districtLabel.text = district;
}

- (void)fetchCandidateInfo{
    [[OpenFECAPI shared]fetchCandidateDetails:self.candidateId completion:^(NSArray *details, NSError *error){
        if(details){
            self.details = details[0];
            dispatch_async(dispatch_get_main_queue(), ^{
               [self setInfoDetails];
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
