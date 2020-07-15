//
//  Assoc.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/15/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Assoc : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) Post *likedPost;
@property (nonatomic, strong) NSString *typeId;

@end

NS_ASSUME_NONNULL_END
