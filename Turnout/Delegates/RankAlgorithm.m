//
//  RankAlgorithm.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/23/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "RankAlgorithm.h"
#import <Parse/Parse.h>

static double const timeWeight = 0.002;
static double const distanceWeight = 0.5;

@implementation RankAlgorithm

+ (instancetype)shared {
    static RankAlgorithm *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)queryPosts:(NSArray *)posts{
    int i = 0;
    for(Post *post in posts){
        [self calculatePostRank:post rank:i];
        i++;
    }
}

- (void)calculatePostRank:(Post *)post rank:(int)i{
    post.rank = @(i);
    [self saveRankToParse:post];
}

- (void)saveRankToParse:(Post *)post{
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The rank was saved!");
        } else {
            NSLog(@"Problem saving rank: %@", error.localizedDescription);
        }
    }];
}

- (void)getDistance{
    
}

- (void)getTimeSinceCreated{
    
}

- (void)orderPostsByRank{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = posts;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
