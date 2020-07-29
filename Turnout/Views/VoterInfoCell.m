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
    self.addressLabel.alpha = 0;
    self.adminLabel.text = self.infoCell[@"desc"];
    self.titleLabel.text = self.infoCell[@"title"];
    if(url == nil){
        self.userInteractionEnabled = NO;
        self.addressLabel.text = self.infoCell[@"address"];
        self.addressLabel.alpha = 1;
    }
}

@end
