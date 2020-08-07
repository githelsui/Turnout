//
//  Comment.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) PFUser *commenter;
@property (nonatomic, strong) NSString *comment;
+ (void)saveComment:(NSString * _Nullable )comment post:(Post * _Nullable)post withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
