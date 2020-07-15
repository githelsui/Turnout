//
//  PostCell.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setCell{
    PFUser *user = self.post.author;
    [user fetchIfNeeded];
    self.nameLabel.text = user[@"username"];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timeAgo;
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            CGPoint point;
            point.x = self.center.x;
            point.y = self.statusLabel.layer.frame.size.height + self.statusLabel.layer.position.y + 100;
            int sides = self.statusLabel.layer.frame.size.width;
            CGRect rect = CGRectMake(0, 0, sides, sides);
            UIImage *img = [UIImage imageWithData:data];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.center = point;
            imageView.bounds = rect;
            imageView.image = img;
            [self addSubview:imageView];
        }else{
            NSLog(@"Print error!!! %@", error.localizedDescription);
            [self.attachedPhoto removeFromSuperview];
            self.attachedPhoto = nil;
        }
    }];
}

@end
