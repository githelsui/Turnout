//
//  CommentCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/7/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CommentCell.h"
#import "DateTools.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setCellContent{
    PFUser *commenter = self.comment.commenter;
    [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if(user){
            self.commenterLabel.text = commenter[@"username"];
        }
    }];
    self.commentLabel.text = self.comment.comment;
    self.timeAgoLabel.text = [self getTimeAgo:self.comment];
}

- (NSString *)getTimeAgo:(Comment *)comment{
    NSDate *createdAt = [comment createdAt];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSTimeInterval seconds = -[createdAt timeIntervalSinceNow];
    NSDate *timeAgo = [NSDate dateWithTimeIntervalSinceNow:seconds];
    NSString *timeAgoString = timeAgo.shortTimeAgoSinceNow;
    return timeAgoString;
}

@end
