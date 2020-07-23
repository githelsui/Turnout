//
//  RankAlgorithm.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/23/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface RankAlgorithm : NSObject
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *timeSinceCreation;
@property (nonatomic, strong) NSArray *posts;
+ (instancetype)shared;
- (void)queryPosts:(NSArray *)posts;
@end

NS_ASSUME_NONNULL_END
