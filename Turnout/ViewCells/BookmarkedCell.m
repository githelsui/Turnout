//
//  BookmarkedCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/5/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "BookmarkedCell.h"

@implementation BookmarkedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell{
    [self createShadows];
    NSString *type = self.bookmarkInfo[@"type"];
    NSDictionary *data = self.bookmarkInfo[@"data"];
    if([type isEqualToString:@"voterInfo"]){
        [self setVoterInfoCell:data];
    } else if([type isEqualToString:@"nationalElection"]){
        [self setNationalElection:data];
    } else if([type isEqualToString:@"stateElection"]){
        [self setStateElection:data];
    } else if([type isEqualToString:@"electDetail"]){
        [self setNationElectDetail:data];
    } else if([type isEqualToString:@"candidateInfo"]){
        [self setCandidate:data];
    } else if([type isEqualToString:@"propInfo"]){
        
    }
}

- (void)createShadows{
    self.bubbleView.clipsToBounds = NO;
    self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bubbleView.layer.shadowRadius = 3;
    self.bubbleView.layer.shadowOpacity = 0.5;
    self.backImg.clipsToBounds = YES;
    self.backImg.layer.cornerRadius = 15;
}

//@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
//@property (weak, nonatomic) IBOutlet UILabel *sideHeaderLbl;
//@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
//@property (weak, nonatomic) IBOutlet UILabel *subHeader;
//@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
//@property (nonatomic, strong) NSDictionary *bookmarkInfo;
//@property (weak, nonatomic) IBOutlet UIView *bubbleView;
//@property (weak, nonatomic) IBOutlet UIImageView *backImg;

- (void)setVoterInfoCell:(NSDictionary *)data{
    NSString *url = data[@"url"];
    self.subHeader.alpha = 0;
    self.sideHeaderLbl.alpha = 0;
    self.headerLabel.text = data[@"desc"];
    self.titleLbl.text = data[@"title"];
       if(url == nil){
           self.userInteractionEnabled = NO;
           self.subHeader.text = data[@"address"];
           self.subHeader.alpha = 1;
       }
}

- (void)setNationalElection:(NSDictionary *)data{
    self.headerLabel.text = [NSString stringWithFormat:@"Election Date: %@", data[@"electionDay"]];
    self.titleLbl.text = data[@"name"];
    self.sideHeaderLbl.alpha = 0;
    self.subHeader.alpha = 0;
}

- (void)setStateElection:(NSDictionary *)data{
    self.headerLabel.text = [NSString stringWithFormat:@"Election Date: %@", data[@"election_date"]];
    NSString *electionNotes = data[@"election_notes"];
    if([electionNotes isEqual:[NSNull null]]){
        self.titleLbl.text = data[@"election_type_full"];
        self.subHeader.text = [self getOfficeSought:data];
    } else {
        self.titleLbl.text = data[@"election_notes"];
        self.subHeader.text = [self getStateDesc:data];
    }
    self.sideHeaderLbl.text = [self getElectionLoc:data];
}

- (void)setNationElectDetail:(NSDictionary *)data{
    NSString *contentType = data[@"type"];
    if([contentType isEqualToString:@"General"]){
        [self setGeneralContest:data];
    } else if([contentType isEqualToString:@"Referendum"]){
        [self setReferendum:data];
    } else {
        [self setVoterInfoCell:data];
    }
}

- (void)setCandidate:(NSDictionary *)data{
    self.sideHeaderLbl.text = data[@"candidateType"];
    self.titleLbl.text = data[@"name"];
    self.headerLabel.text = data[@"office"];
    self.subHeader.text = data[@"party"];
}

- (void)setPropInfo:(NSDictionary *)data{
    self.headerLabel.text =  [NSString stringWithFormat: @"Legislative Date: %@", data[@"legislative_day"]];
    [self setPropositionTitle:data];
}

- (void)setPropositionTitle:(NSDictionary *)data{
    NSString *fullTitle = data[@"description"];
    NSString *newTitle = @"";
    NSArray *chunks = [fullTitle componentsSeparatedByString: @" "];
    for(NSString *word in chunks){
        NSString *firstLetter = [word substringWithRange:NSMakeRange(0, 1)];
        if([firstLetter isEqualToString:@"["]){
            break;
        } else {
            NSString *toAdd = [NSString stringWithFormat: @"%@ ", word];
            newTitle = [newTitle stringByAppendingString:toAdd];
        }
    }
    self.titleLbl.text = newTitle;
}

- (void)setGeneralContest:(NSDictionary *)data{
    self.headerLabel.text = data[@"type"];
    self.titleLbl.text = data[@"office"];
    self.subHeader.text = [self getCandidateInfo:data];
}

- (void)setReferendum:(NSDictionary *)data{
    self.headerLabel.text = data[@"type"];
    self.titleLbl.text = data[@"office"];
    self.subHeader.text = data[@"description"];
}

- (NSString *)getCandidateInfo:(NSDictionary *)data{
    NSArray *candidates = data[@"candidates"];
    NSString *desc = @"Candidates: \r\r";
    for(NSDictionary *candidate in candidates){
        NSString *name = candidate[@"name"];
        NSString *party = candidate[@"party"];
        NSString *candidateStr = [NSString stringWithFormat:@"%@ | %@\r", name, party];
         desc = [desc stringByAppendingString:candidateStr];
    }
    NSLog(@"candidate info string: %@", desc);
    return desc;
}

- (NSString *)getStateDesc:(NSDictionary *)data{
    NSString *electionType = data[@"election_type_full"];
    NSString *office = [self getOfficeSought:data];
    NSString *returnStr = [NSString stringWithFormat:@"%@ \r%@", electionType, office];
    return returnStr;
}

- (NSString *)getElectionLoc:(NSDictionary *)data{
    NSString *state = data[@"election_state"];
    NSString *district = data[@"election_district"];
    NSString *loc;
    if(data[@"election_district"] == nil){
        loc = state;
    } else {
        loc  = [NSString stringWithFormat:@"District %@, %@", district, state];
    }
    return loc;
}

- (NSString *)getOfficeSought:(NSDictionary *)data{
    NSString *key = data[@"office_sought"];
    if([key isEqualToString:@"H"]) return @"Office Sought: House of Representatives";
    else if([key isEqualToString:@"S"]) return @"Office Sought: Senate";
    else return @"Office Sought: Presidential";
}

@end
