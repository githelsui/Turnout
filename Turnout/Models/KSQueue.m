//  KSQueue.m
//  StackAndQueue
//  Created by Debasis Das on 10/1/15.
//  Copyright © 2015 Knowstack. All rights reserved.

#import "KSQueue.h"
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

-(void)enqueue:(id)anObject{
    [self.data addObject:anObject];
}

-(id)dequeue{
    id headObject = [self.data objectAtIndex:0];
    if (headObject != nil) {
        [self.data removeObjectAtIndex:0];
    }
    return headObject;
}

@end
