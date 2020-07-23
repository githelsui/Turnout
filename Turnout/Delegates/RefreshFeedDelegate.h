//
//  RefreshFeedDelegate.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/23/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RefreshFeedDelegate
- (void)refreshFeed;
- (void)postToTopFeed:(Post *)post;
@end

NS_ASSUME_NONNULL_END
