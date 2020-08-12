//
//  CandidateCell.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CandidateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backColor;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *partyLabel;
@property (nonatomic, strong) NSMutableDictionary *candidate;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic, strong) NSString *state;
@property (nonatomic) BOOL didBookmark;
- (void)setCell;
@end

NS_ASSUME_NONNULL_END
