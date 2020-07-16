//
//  Post.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Post.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic status;
@dynamic uiImage;
@dynamic image;
@dynamic photoAttached;
@dynamic datePosted;
@dynamic timePosted;
@dynamic timeAgo;
@dynamic likeAssocs;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postStatus:(UIImage * _Nullable )image withStatus: (NSString * _Nullable )status date: (NSString * _Nullable )date time: (NSString * _Nullable )time imgAttached:(BOOL)imgAttached withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.status = status;
    newPost.photoAttached = imgAttached;
    newPost.timeAgo = [newPost getTimeAgo: newPost];
    newPost.datePosted = date;
    newPost.timePosted = time;
    [newPost saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (NSArray *)postsWithArray:(NSArray *)posts{
    NSMutableArray *newPosts = [NSMutableArray array];
    for (Post *post in posts) {
        post.uiImage = [post fetchUIImage];
//        post.likeCount = [post fetchLikeCount];
        [newPosts addObject:post];
    }
    NSArray *arrPosts = [newPosts copy];
    return arrPosts;
}

- (UIImage *)fetchUIImage{
    [self.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:data];
            self.uiImage = img;
        }else{
            NSLog(@"Print error!!! %@", error.localizedDescription);
        }
    }];
    return self.uiImage;
}

- (void)fetchLikeAssocs{
    PFQuery *query = [PFQuery queryWithClassName:@"Assoc"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"typeId" equalTo:@"Like"];
    [query whereKey:@"likedPost" equalTo:self];
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        if (likes != nil) {
            self.likeAssocs = likes;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSString *)getTimeAgo: (Post *)post{
    NSDate *createdAt = post.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm";
    //    NSString *date = [formatter stringFromDate:createdAt];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.dateFormat = @"E MMM d";
    NSString *shortDate = [formatter stringFromDate:createdAt];
    return shortDate;
}

@end
