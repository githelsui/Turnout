//  KSQueue.h
//  StackAndQueue
//  Created by Debasis Das on 10/1/15.
//  Copyright © 2015 Knowstack. All rights reserved.

#import <Foundation/Foundation.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSQueue : NSObject

-(void)enqueue:(NSDictionary *)anObject;
-(id)dequeue;
- (NSUInteger)getSize;
- (BOOL)contains:(Post *)post;

@end

NS_ASSUME_NONNULL_END
