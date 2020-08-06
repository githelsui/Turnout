//
//  VoterInfoCell.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoterInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (nonatomic, strong) NSMutableDictionary *infoCell;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic) BOOL didBookmark;
- (void)setCell;
- (void)setPropCell;
- (void)createShadows;
- (void)checkBookmark;
- (void)loadBookmarks;
@end

NS_ASSUME_NONNULL_END
