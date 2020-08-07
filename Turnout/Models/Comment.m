//
//  Comment.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic post;
@dynamic comment;
@dynamic commenter;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void)saveComment:(NSString * _Nullable )comment post:(Post * _Nullable)post withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Comment *newComment = [Comment new];
    newComment.post = post;
    newComment.comment = comment;
    newComment.commenter = PFUser.currentUser;
    [newComment saveInBackgroundWithBlock: completion];
}

@end
