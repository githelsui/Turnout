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
    NSDictionary *candInfo = self.candidate[@"candidate"];
    [self checkBookmark];
    [self loadBookmarks];
    [self createShadows];
    self.typeLabel.text = self.state;
    self.nameLabel.text = candInfo[@"name"];
    self.officeLabel.text = @"Congressional Candidate";
    self.partyLabel.text = [self getParty:candInfo[@"party"]];
}

- (NSString *)getParty:(NSString *)type{
    if([type isEqualToString:@"DEM"]) return @"Democratic Party";
    else return @"Republican Party";
}

- (void)createShadows{
     self.bubbleView.clipsToBounds = NO;
     self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
     self.bubbleView.layer.shadowRadius = 5;
     self.bubbleView.layer.shadowOpacity = 0.5;
     self.backColor.clipsToBounds = YES;
     self.backColor.layer.cornerRadius = 15;
}

- (IBAction)bookmarkTap:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSDate *bookmarkInfo = [self getBookmarkInfo:@"candidateInfo"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:[self.bookmarks copy] forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[NSKeyedArchiver archivedDataWithRootObject:self.myDictionary]
    } else {
        [self removeBookmark];
    }
}

- (void)removeBookmark{
    self.didBookmark = NO;
    UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
    [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    [self.bookmarks removeObject:self.bookmarkInfo];
    [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)getBookmarkInfo:(NSString *)type{
    NSMutableDictionary *bookmarkInfo = [NSMutableDictionary new];
    [bookmarkInfo setValue:type forKey:@"type"];
    [bookmarkInfo setValue:self.candidate forKey:@"data"];
    NSData *data =  [NSKeyedArchiver archivedDataWithRootObject:[bookmarkInfo copy]];
    return data;
}

- (void)checkBookmark{
    self.didBookmark = NO;
    self.bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    for(NSData *bookmark in self.bookmarks){
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmark];
        NSDictionary *data = bookmarkDict[@"data"];
        NSDictionary *compare = [self.candidate copy];
        if([data isEqual:compare]){
            self.bookmarkInfo = bookmark;
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

@end
