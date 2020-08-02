//
//  CandidateCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CandidateCell.h"

@implementation CandidateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell{
    self.backColor.alpha = 0.70;
    self.bubbleView.clipsToBounds = true;
    self.bubbleView.layer.cornerRadius = 15;
    self.typeLabel.text = self.candidate[@"candidateType"];
    self.nameLabel.text = self.candidate[@"name"];
    self.officeLabel.text = self.candidate[@"office"];
    self.partyLabel.text = self.candidate[@"party"];
}

@end
