//
//  Post.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSString *timeAgo;
@property (nonatomic, strong) NSString *datePosted;
@property (nonatomic, strong) NSString *timePosted;
@property (nonatomic, strong) NSNumber *rank;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (void) postStatus:(UIImage * _Nullable )image withStatus: (NSString * _Nullable )status date: (NSString * _Nullable )date time: (NSString * _Nullable )time withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (Post *)createNewPost:(UIImage * _Nullable )image withStatus: (NSString * _Nullable )status date: (NSString * _Nullable )date time: (NSString * _Nullable )time;
- (NSString *)getTimeAgo: (Post *)post;
@end

NS_ASSUME_NONNULL_END
