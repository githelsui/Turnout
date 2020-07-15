//
//  PostDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PostDetailController.h"

@interface PostDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachedPhoto;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesBtn;

@end

@implementation PostDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI{
    PFUser *user = self.post.author;
    [user fetchIfNeeded];
    self.nameLabel.text = user[@"username"];
    self.statusLabel.text = self.post.status;
    self.timeLabel.text = self.post.timePosted;
    self.dateLabel.text = self.post.datePosted;
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:data];
            self.attachedPhoto.image = img;
        }else{
            NSLog(@"Print error!!! %@", error.localizedDescription);
        }
    }];
//    [self checkImageView];
}

- (void)checkImageView{
    if(self.post.image == nil){
        [self.attachedPhoto removeFromSuperview];
        self.attachedPhoto = nil;
        CGFloat screenWidth = self.view.bounds.size.width;
        CGFloat locationWidth = self.locationLabel.layer.frame.size.width;
        CGSize statusSize = self.statusLabel.layer.frame.size;
        CGPoint statusPos = self.statusLabel.layer.position;
        CGPoint locPoint;
        locPoint.x = (screenWidth + locationWidth - statusSize.width) / 2;
        locPoint.y = statusSize.height + statusPos.y + 10;
        CGPoint likePoint;
        likePoint.x = screenWidth - self.likesBtn.layer.frame.size.width;
        likePoint.y = statusSize.height + statusPos.y + 10;
        self.locationLabel.layer.position = locPoint;
        self.likesBtn.center = likePoint;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
