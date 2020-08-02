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

- (void)setBack{
     self.backColor.alpha = 0.70;
     self.bubbleView.clipsToBounds = true;
     self.bubbleView.layer.cornerRadius = 15;
}

- (void)setCell:(NSString *)contentType{
    [self setBack];
    if([contentType isEqualToString:@"General"]){
        [self setGeneralContest];
    } else if([contentType isEqualToString:@"Referendum"]){
        [self setReferendum];
    } else {
        [self setVoterInfo];
    }
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
