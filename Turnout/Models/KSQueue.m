//  KSQueue.m
//  StackAndQueue
//  Created by Debasis Das on 10/1/15.
//  Copyright © 2015 Knowstack. All rights reserved.

#import "KSQueue.h"
#import <Parse/Parse.h>

@interface KSQueue()
@property (strong) NSMutableArray *data;
@end

@implementation KSQueue
-(instancetype)init{
    if (self = [super init]){
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)enqueue:(NSDictionary *)anObject{
    [self.data addObject:anObject];
    self.data = [self sortPostsArr:self.data];
    NSLog(@"items in queue = %@" , self.data);
    
}

-(NSDictionary *)dequeue{
    NSDictionary *headObject = [self.data objectAtIndex:0];
    if (headObject != nil) {
        [self.data removeObjectAtIndex:0];
    }
    return headObject;
}

- (BOOL)contains:(Post *)post{
    NSString *postId = [post objectId];
    for(NSDictionary *obj in self.data){
        Post *temp = obj[@"post"];
        NSString *tempId = [temp objectId];
        if([postId isEqual:tempId])
            return YES;
    }
    return NO;
}

- (NSUInteger)getSize{
    return self.data.count;
}

- (NSMutableArray *)sortPostsArr:(NSMutableArray *)postDicts{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:YES];
    NSArray *sortedArray = [postDicts sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [sortedArray mutableCopy];
}

- (KSQueue *)getSortedQueue{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:YES];
    NSArray *sortedArray = [self.data sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [sortedArray mutableCopy];
}

@end
