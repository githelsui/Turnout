//
//  CommentCell.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/7/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commenterLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (nonatomic, strong) Comment *comment;
- (void)setCellContent;
@end

NS_ASSUME_NONNULL_END
