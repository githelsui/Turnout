//
//  VoterInfoCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VoterInfoCell.h"

@implementation VoterInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setCell{
    NSString *url = self.infoCell[@"url"];
    self.bubbleView.alpha = 1;
    self.backImage.alpha = 0.70;
    self.bubbleView.clipsToBounds = true;
    self.bubbleView.layer.cornerRadius = 15;
    self.addressLabel.alpha = 0;
    self.adminLabel.text = self.infoCell[@"desc"];
    self.titleLabel.text = self.infoCell[@"title"];
    if(url == nil){
        self.userInteractionEnabled = NO;
        self.addressLabel.text = self.infoCell[@"address"];
        self.addressLabel.alpha = 1;
    }
}

- (void)setPropCell{
    self.bubbleView.alpha = 1;
    self.bubbleView.clipsToBounds = true;
    self.bubbleView.layer.cornerRadius = 15;
    NSString *date = [NSString stringWithFormat: @"Legislative Date: %@", self.infoCell[@"legislative_day"]];
    self.adminLabel.text = date;
    [self setPropositionTitle];
}

- (void)setPropositionTitle{
    NSString *fullTitle = self.infoCell[@"description"];
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
    self.titleLabel.text = newTitle;
}

@end
