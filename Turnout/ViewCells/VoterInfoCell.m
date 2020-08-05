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
    self.addressLabel.alpha = 0;
    [self createShadows];
    self.adminLabel.text = self.infoCell[@"desc"];
    self.titleLabel.text = self.infoCell[@"title"];
    if(url == nil){
        self.userInteractionEnabled = NO;
        self.addressLabel.text = self.infoCell[@"address"];
        self.addressLabel.alpha = 1;
    }
}

- (void)createShadows{
     self.bubbleView.clipsToBounds = NO;
     self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
     self.bubbleView.layer.shadowRadius = 5;
     self.bubbleView.layer.shadowOpacity = 0.5;
     self.backImage.clipsToBounds = YES;
     self.backImage.layer.cornerRadius = 15;
}

- (void)setPropCell{
    self.bubbleView.alpha = 1;
    [self createShadows];
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

//create NSUser defaults arr in the livefeed
//use NSUser defaults to store an array of current user's bookmarked info (stored as NSDictionary)
   //fetch NSUser defaults for bookmarked info array, loop through to check if bookmarked info is inside the array
   // if it exists in arr -> user has already bookmarked it = change btn image to 'didBookmark' else not, do nothing
   //to pass in this data to detail view, use a public var in detail class called 'didBookmark' (BOOL) and set it to the right value inside the method forEachCellAtRowPath

- (IBAction)tapBookmark:(id)sender {
   //if didBookmark == false --> change btn image to didBookmark and add to the arr then save it back to NSUserDefaults
   //if didBookmark == true -> change img to notBookmarked and update the array with the removed NSDictionary
    
    //the array that will be stored in NSUserDefaults == conntains nsdictionaries with two key value pairs
    // 'type' : either 'voterInfo', 'nationalElection', 'stateElection',  'electDetail', 'candidateInfo', 'propInfo'
    // 'data' : the actual NSDictionary
    
    
    //how to differentiate between what types of info in the bookmarks tab so that you can segue to the correct screen
    //  --> if(bookmark.type == 'secific key') manually programmtically create a segue to correct view controller
}


@end
