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
    [self checkBookmark];
    [self loadBookmarks];
    NSString *url = self.infoCell[@"url"];
    self.bubbleView.alpha = 1;
    self.backImage.alpha = 0.70;
    self.addressLabel.alpha = 0;
    [self createShadows];
    self.adminLabel.text = self.infoCell[@"desc"];
    self.titleLabel.text = self.infoCell[@"title"];
    if(url == nil){
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
    [self checkBookmark];
    [self loadBookmarks];
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

- (void)loadBookmarks{
    if(self.didBookmark == YES){
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    } else {
        UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    }
}

- (IBAction)saveElectTap:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSData *bookmarkInfo = [self getBookmarkInfo:@"nationalElection"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self removeBookmark];
    }
}

- (IBAction)tapBookmark:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSData *bookmarkInfo = [self getBookmarkInfo:@"voterInfo"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:[self.bookmarks copy] forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self removeBookmark];
    }
}

- (IBAction)saveBillTap:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSData *bookmarkInfo = [self getBookmarkInfo:@"propInfo"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:[self.bookmarks copy] forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    [bookmarkInfo setValue:self.infoCell forKey:@"data"];
    NSData *data =  [NSKeyedArchiver archivedDataWithRootObject:[bookmarkInfo copy]];
    return data;
}

- (void)checkBookmark{
    self.didBookmark = NO;
    self.bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    for(NSData *bookmark in self.bookmarks){
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmark];
        NSDictionary *data = bookmarkDict[@"data"];
        NSDictionary *compare = [self.infoCell copy];
        if([data isEqual:compare]){
            self.bookmarkInfo = bookmark;
            self.didBookmark = YES;
        }
    }
}


@end
