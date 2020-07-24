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
@dynamic likeCount;
@dynamic status;
@dynamic image;
@dynamic rank;
@dynamic datePosted;
@dynamic timePosted;
@dynamic timeAgo;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postStatus:(UIImage * _Nullable )image withStatus: (NSString * _Nullable )status date: (NSString * _Nullable )date time: (NSString * _Nullable )time withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.status = status;
    newPost.likeCount = @(0);
    newPost.rank = @(0);
    newPost.timeAgo = [newPost getTimeAgo: newPost];
    newPost.datePosted = date;
    newPost.timePosted = time;
    [newPost saveInBackgroundWithBlock: completion];
}

+ (Post *)createNewPost:(UIImage * _Nullable )image withStatus: (NSString * _Nullable )status date: (NSString * _Nullable )date time: (NSString * _Nullable )time{
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.status = status;
    newPost.likeCount = @(0);
    newPost.rank = @(0);
    newPost.zipcode = [PFUser currentUser][@"zipcode"];
    newPost.timeAgo = [newPost getTimeAgo: newPost];
    newPost.datePosted = date;
    newPost.timePosted = time;
    return newPost;
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
