//
//  RankAlgorithm.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/23/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "RankAlgorithm.h"
#import <Parse/Parse.h>
#import "Zipcode.h"

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

- (NSArray *)queryPosts:(NSArray *)posts{
    __block NSArray *rankedFeed = nil;
    for(Post *post in posts){
        [self calculatePostRank:post];
    }
    rankedFeed = [self orderPostsByRank];
    return rankedFeed;
}

- (void)calculatePostRank:(Post *)post{
//    post.rank = post.likeCount;
    PFUser *postUser = post.author;
    PFUser *currentUser = PFUser.currentUser;
    Zipcode *postZipcode = [self getZipcode:postUser];
    Zipcode *currentZipcode = [self getZipcode:currentUser];
    NSArray *postNeighbors = postZipcode.neighbors;
    NSLog(@"post neighbors for zipcode: %@ are = %@", postZipcode, postNeighbors);
    NSArray *currentNeighbors = currentZipcode.neighbors;
    
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

- (Zipcode *)getZipcode:(PFUser *)user{
    __block Zipcode *zip = nil;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error){
           if(user){
               zip = user[@"zipcode"];
           }
    }];
    return zip;
}

- (void)getDistance{
    
}

- (void)getTimeSinceCreated{
    
}

- (NSArray *)orderPostsByRank{
    __block NSArray *rankedFeed = nil;
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            rankedFeed = posts;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    return rankedFeed;
}

@end
