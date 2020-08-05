//
//  ElectionDetailCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ElectionDetailCell.h"

@implementation ElectionDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createShadows{
     self.bubbleView.clipsToBounds = NO;
     self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
     self.bubbleView.layer.shadowRadius = 5;
     self.bubbleView.layer.shadowOpacity = 0.5;
    
     self.backColor.clipsToBounds = YES;
     self.backColor.layer.cornerRadius = 15;
}

- (void)setCell:(NSString *)contentType{
    [self createShadows];
    if([contentType isEqualToString:@"General"]){
        [self setGeneralContest];
    } else if([contentType isEqualToString:@"Referendum"]){
        [self setReferendum];
    } else {
        [self setVoterInfo];
    }
}

- (void)setStateElection{
    [self createShadows];
    self.backColor.alpha = 0.70;
    self.header.text = [NSString stringWithFormat:@"Election Date: %@", self.content[@"election_date"]];
    NSString *electionNotes = self.content[@"election_notes"];
    if([electionNotes isEqual:[NSNull null]]){
        self.title.text = self.content[@"election_type_full"];
        self.descLabel.text = [self getOfficeSought];
    } else {
        self.title.text = self.content[@"election_notes"];
        self.descLabel.text = [self getStateDesc];
    }
    self.locLabel.text = [self getElectionLoc];
}

- (NSString *)getElectionLoc{
    NSString *state = self.content[@"election_state"];
    NSString *district = self.content[@"election_district"];
    NSString *loc;
    if(self.content[@"election_district"] == nil){
        loc = state;
    } else {
        loc  = [NSString stringWithFormat:@"District %@, %@", district, state];
    }
    return loc;
}

- (NSString *)getStateDesc{
    NSString *electionType = self.content[@"election_type_full"];
    NSString *office = [self getOfficeSought];
    NSString *returnStr = [NSString stringWithFormat:@"%@ \r%@", electionType, office];
    return returnStr;
}

- (NSString *)getOfficeSought{
    NSString *key = self.content[@"office_sought"];
    if([key isEqualToString:@"H"]) return @"Office Sought: House of Representatives";
    else if([key isEqualToString:@"S"]) return @"Office Sought: Senate";
    else return @"Office Sought: Presidential";
}

//header, title, desclabel
- (void)setGeneralContest{
    self.header.text = self.content[@"type"];
    self.title.text = self.content[@"office"];
    self.descLabel.text = [self getCandidateInfo];
}

- (NSString *)getCandidateInfo{
    NSArray *candidates = self.content[@"candidates"];
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

- (void)setReferendum{
    self.header.text = self.content[@"type"];
    self.title.text = self.content[@"office"];
    self.descLabel.text = self.content[@"description"];
}

- (void)setVoterInfo{
    NSString *url = self.content[@"url"];
    self.descLabel.alpha = 0;
    self.header.text = self.content[@"desc"];
    self.title.text = self.content[@"title"];
    if(url == nil){
           self.userInteractionEnabled = NO;
           self.descLabel.text = self.content[@"address"];
           self.descLabel.alpha = 1;
    }
}

@end
