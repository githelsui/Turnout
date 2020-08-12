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
    [self checkBookmark];
    [self loadBookmarks];
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
        [self setPropInfo:data];
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

- (void)setVoterInfoCell:(NSDictionary *)data{
    NSString *url = data[@"url"];
    self.subHeader.alpha = 0;
    self.sideHeaderLbl.alpha = 0;
    self.headerLabel.alpha = 1;
    self.headerLabel.text = data[@"desc"];
    self.titleLbl.alpha = 1;
    self.titleLbl.text = data[@"title"];
    if(url == nil){
//        self.userInteractionEnabled = NO;
        self.subHeader.text = data[@"address"];
        self.subHeader.alpha = 1;
    }
}

- (void)setNationalElection:(NSDictionary *)data{
    self.headerLabel.alpha = 1;
    self.headerLabel.text = [NSString stringWithFormat:@"Election Date: %@", data[@"electionDay"]];
    self.titleLbl.alpha = 1;
    self.titleLbl.text = data[@"name"];
    self.sideHeaderLbl.alpha = 0;
    self.subHeader.alpha = 0;
}

- (void)setStateElection:(NSDictionary *)data{
    self.headerLabel.alpha = 1;
    self.headerLabel.text = [NSString stringWithFormat:@"Election Date: %@", data[@"election_date"]];
    NSString *electionNotes = data[@"election_notes"];
    if([electionNotes isEqual:[NSNull null]]){
        self.titleLbl.alpha = 1;
        self.titleLbl.text = data[@"election_type_full"];
        self.subHeader.alpha = 1;
        self.subHeader.text = [self getOfficeSought:data];
    } else {
        self.titleLbl.alpha = 1;
        self.titleLbl.text = data[@"election_notes"];
        self.subHeader.alpha = 1;
        self.subHeader.text = [self getStateDesc:data];
    }
    self.sideHeaderLbl.alpha = 1;
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
    NSDictionary *candInfo = data[@"candidate"];
    NSString *partyTemp = candInfo[@"party"];
    self.sideHeaderLbl.alpha = 0;
    self.titleLbl.alpha = 1;
    self.titleLbl.text = candInfo[@"name"];
    self.headerLabel.alpha = 1;
    self.headerLabel.text = @"Congressional Candidate";
    self.subHeader.alpha = 1;
    self.subHeader.text = [self getParty:partyTemp];
}

- (NSString *)getParty:(NSString *)type{
    if([type isEqualToString:@"DEM"]) return @"Democratic Party";
    else return @"Republican Party";
}

- (void)setPropInfo:(NSDictionary *)data{
    self.headerLabel.alpha = 1;
    self.sideHeaderLbl.alpha = 0;
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
    self.titleLbl.alpha = 1;
    self.titleLbl.text = newTitle;
}

- (void)setGeneralContest:(NSDictionary *)data{
    self.headerLabel.alpha = 1;
    self.headerLabel.text = data[@"type"];
    self.titleLbl.alpha = 1;
    self.titleLbl.text = data[@"office"];
    self.subHeader.alpha = 1;
    self.subHeader.text = [self getCandidateInfo:data];
    self.sideHeaderLbl.alpha = 0;
}

- (void)setReferendum:(NSDictionary *)data{
    self.headerLabel.alpha = 1;
    self.headerLabel.text = data[@"type"];
    self.titleLbl.alpha = 1;
    self.titleLbl.text = data[@"office"];
    self.subHeader.alpha = 1;
    self.subHeader.text = data[@"description"];
    self.sideHeaderLbl.alpha = 0;
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

- (void)checkBookmark{
    self.didBookmark = NO;
    self.bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    for(NSData *bookmark in self.bookmarks){
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmark];
        NSDictionary *data = bookmarkDict[@"data"];
        NSDictionary *compare = [self.bookmarkInfo[@"data"] copy];
        if([data isEqual:compare]){
            self.bookmarkData = bookmark;
            self.didBookmark = YES;
        }
    }
}

- (void)loadBookmarks{
    if(self.didBookmark == YES){
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    } else {
        UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    }
}

- (NSDictionary *)getBookmarkInfo:(NSString *)type{
    NSMutableDictionary *bookmarkInfo = [NSMutableDictionary new];
    [bookmarkInfo setValue:type forKey:@"type"];
    [bookmarkInfo setValue:self.bookmarkInfo[@"data"] forKey:@"data"];
    return [bookmarkInfo copy];
}

- (void)removeBookmark{
    self.didBookmark = NO;
    UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
    [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    [self.bookmarks removeObject:self.bookmarkData];
    [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)bookmarkTap:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSDictionary *bookmarkInfo = [self getBookmarkInfo:@"stateElection"];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bookmarkInfo];
        [self.bookmarks addObject:data];
        [[NSUserDefaults standardUserDefaults] setObject:[self.bookmarks copy] forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self removeBookmark];
    }
}


@end
