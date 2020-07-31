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
#import "PriorityQueue.h"
#import "KSQueue.h"

static float const timeWeight = 0.000005;

@interface RankAlgorithm ()
@property (nonatomic, strong) NSMutableArray *postDicts;
@property (nonatomic, strong, retain) NSMutableArray *individualQueues;
@property (nonatomic, strong, retain) Zipcode *currentZip;
@property (nonatomic, strong) PriorityQueue *priorityQueue;

@end

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
    self.neighborDicts =  [NSMutableArray array];
    self.individualQueues = [NSMutableArray array];
    self.posts =  [NSMutableArray array];
    self.priorityQueue = [PriorityQueue new];
    return self;
}

- (void)queryPosts:(int)skip completion:(void(^)(NSArray *posts, NSError *error))completion{
    if(skip == 0) [self.livefeed removeAllObjects];
    [self.neighborDicts removeAllObjects];
    [self.posts removeAllObjects];
    [self.individualQueues removeAllObjects];
    [self getCurrentUserInfo:^(NSArray *neighbors, NSError *error){
        self.neighborDicts = [neighbors mutableCopy];
        NSLog(@"final neighborDicts array: %@", neighbors);
        if(neighbors){
            [self fetchNeighboringPosts:neighbors skip:skip completion:^(NSMutableArray *individualQueues, NSError *error){
                if(individualQueues){
                    [self fetchFarPosts:skip completion:^(NSMutableArray *farPosts, NSError *error){
                        if(self.individualQueues.count > 0){
                            [self beginMerge:self.individualQueues];
                            [self mergeBatches];
                            completion(self.posts, nil);
                        } else{
                            completion(self.posts, nil);
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)getCurrentUserInfo:(void(^)(NSArray *neighbors, NSError *error))completion{
    PFUser *currentUser = PFUser.currentUser;
    self.currentZip = currentUser[@"zipcode"];
    [self fetchNeighbors:self.currentZip completion:^(NSArray *neighbors, NSError *error){
        if(neighbors){
            [self getNeighboringDicts:neighbors completion:^(NSArray *neighborDicts, NSError *error){
                self.neighborDicts = [neighborDicts mutableCopy];
                completion(neighborDicts, nil);
            }];
        }
    }];
}

- (void)getNeighboringDicts:(NSArray *)neighbors completion:(void(^)(NSArray *neighborDicts, NSError *error))completion{
    for(NSDictionary *neighbor in neighbors){
        [self findExistingZip:neighbor[@"zipcode"] completion:^(NSArray *returnNeighbors, NSError *error){
            if(returnNeighbors){
                NSMutableDictionary *tempZip = [[NSMutableDictionary alloc] init];
                Zipcode *zipObj = returnNeighbors[0];
                [tempZip setObject:zipObj forKey:@"zipcode"];
                [tempZip setObject:neighbor[@"distance"] forKey:@"distance"];
                [self.neighborDicts addObject:tempZip];
                NSDictionary *lastObj = [neighbors lastObject];
                if([neighbor isEqual:lastObj]){
                    completion(self.neighborDicts, nil);
                }
            }
        }];
    }
}

- (void)findExistingZip:(NSString *)zipcode completion:(void(^)(NSArray *neighbors, NSError *error))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcode"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [query includeKey:@"objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *zips, NSError *error) {
        if (zips.count > 0) {
            completion(zips, error);
        } else {
            NSLog(@"%s", "no zipcode found");
            completion(nil, error);
        }
    }];
}

- (void)fetchNeighboringPosts:(NSArray *)zipcodes skip:(int)skip completion:(void(^)(NSMutableArray *neighborsPosts, NSError *error))completion{
    for(NSDictionary *zipcode in zipcodes){
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        [query orderByDescending:@"likeCount"];
        [query whereKey:@"zipcode" equalTo:zipcode[@"zipcode"]];
        NSString *key = zipcode[@"zipcode"][@"zipcode"];
        NSString *lastItem = zipcodes.lastObject[@"zipcode"][@"zipcode"];
        NSLog(@"dict: %@", key);
        [query setLimit:2];
        [query setSkip:skip];
        [query includeKey:@"zipcode"];
        [query includeKey:@"objectId"];
        [query includeKey:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if(results.count > 0){
                NSMutableDictionary *batch = [[NSMutableDictionary alloc] init];
                [batch setObject:key forKey:@"zipcode"];
                
                [self queuePerBatch:results zipcode:zipcode completion:^(KSQueue *posts, NSError *error){
                    [batch setObject:posts forKey:@"queue"];
                }];
                
                [self.individualQueues addObject:batch];
                if([lastItem isEqualToString:key]){
                    NSLog(@"the neighboring posts 1: %@", self.individualQueues);
                    completion(self.individualQueues, nil);
                }
            } else {
                if([lastItem isEqualToString:key]){
                    NSLog(@"no items in results");
                    completion(self.individualQueues, nil);
                }
            }
        }];
    }
}

- (void)queuePerBatch:(NSArray *)posts zipcode:(NSDictionary *)zipcode completion:(void(^)(KSQueue *posts, NSError *error))completion{
    KSQueue *queue = [[KSQueue alloc] init];
    Zipcode *zip = zipcode[@"zipcode"];
    for(Post *post in posts){
        NSMutableDictionary *postValues = [[NSMutableDictionary alloc] init];
        [postValues setObject:post[@"likeCount"] forKey:@"rank"];
        [postValues setObject:zip forKey:@"zipcode"];
        [postValues setObject:post forKey:@"post"];
        if([self livefeedContainsPost:post] == NO)
            [queue enqueue:postValues];
    }
    completion(queue, nil);
}

- (void)fetchFarPosts:(int)skip completion:(void(^)(NSMutableArray *neighborsPosts, NSError *error))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    for(NSDictionary *zipcode in self.neighborDicts){
        Zipcode *zip = zipcode[@"zipcode"];
        [query whereKey:@"zipcode" notEqualTo:zip];
    }
    [query orderByDescending:@"likeCount"];
    [query setLimit:2];
    [query setSkip:skip];
    [query includeKey:@"zipcode"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"objectId"];
    [query includeKey:@"likeCount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results.count > 0){
            for(Post *post in results){
                if([self livefeedContainsPost:post] == NO){
                     [self createPostBatch:post];
                 }
            }
            NSLog(@"far away batches: %@", self.individualQueues);
            completion(self.individualQueues, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)createPostBatch:(Post *)post{
    Zipcode *zip = post[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *key = zip[@"zipcode"];
            NSMutableDictionary *batch = [self getZipcodeBatch:key];
            if(batch){
                NSUInteger index = [self.individualQueues indexOfObject:batch];
                KSQueue *queue = batch[@"queue"];
                if([queue contains:post] == NO){
                      KSQueue *updatedQueue = [self updatePostQueue:post postArr:queue];
                      [batch setObject:updatedQueue forKey:@"queue"];
                      [self.individualQueues replaceObjectAtIndex:index withObject:batch];
                }
            } else {
                    NSMutableDictionary *newBatch = [[NSMutableDictionary alloc] init];
                    KSQueue *queue = batch[@"queue"];
                    KSQueue *updatedQueue =  [self updatePostQueue:post postArr:queue];
                    [newBatch setObject:key forKey:@"zipcode"];
                    [newBatch setObject:updatedQueue forKey:@"queue"];
                    [self.individualQueues addObject:newBatch];
            }
        }
    }];
}

- (KSQueue *)updatePostQueue:(Post *)post postArr:(KSQueue *)queue{
    KSQueue *copy = queue;
    NSMutableDictionary *tempPost = [[NSMutableDictionary alloc] init];
    [tempPost setObject:post[@"likeCount"] forKey:@"rank"];
    [tempPost setObject:post[@"zipcode"] forKey:@"zipcode"];
    [tempPost setObject:post forKey:@"post"];
    [copy enqueue:tempPost];
    return copy;
}

- (BOOL)livefeedContainsPost:(Post *)post{
    for(Post *livepost in self.livefeed){
        NSString *postId = [livepost objectId];
        NSString *currentId = [post objectId];
        if([postId isEqual:currentId])
            return YES;
    }
    return NO;
}

- (void)beginMerge:(NSArray *)individualQueues{
    for(NSDictionary *batch in individualQueues){
        KSQueue *queue = batch[@"queue"];
        NSDictionary *first = [queue dequeue];
        [self.priorityQueue add:first];
    }
    NSLog(@"posts inside priorityQueue: %@", self.priorityQueue);
}

- (void)mergeBatches{
    if(self.priorityQueue.size != 0) {
        NSDictionary *priorityPost = [self.priorityQueue poll];
        [self.posts addObject:priorityPost[@"post"]];
        Zipcode *zipcode = priorityPost[@"zipcode"];
        NSString *zipStr = zipcode[@"zipcode"];
        NSMutableDictionary *batch = [self getZipcodeBatch:zipStr];
        KSQueue *posts = batch[@"queue"];
        if([posts getSize] == 0){
            [self fetchZipcodeBatch:zipcode];
        } else if([posts getSize] > 0){
            NSDictionary *firstElement = [posts dequeue];
            [self addToPriorityQueue:firstElement batch:batch];
        } //batch is exhausted in database
    } else {
        self.posts = [[[self.posts reverseObjectEnumerator] allObjects] mutableCopy];
    }
}

- (void)addToPriorityQueue:(NSDictionary *)post batch:(NSDictionary *)batch{
    KSQueue *posts = batch[@"queue"];
    if([posts getSize] == 0){
        [self.priorityQueue add:post];
        [self mergeBatches];
    }
}

- (void)fetchZipcodeBatch:(Zipcode *)zipcode{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"likeCount"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [query setLimit:2];
    [query setSkip:2];
    [query includeKey:@"zipcode"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"objectId"];
    [query includeKey:@"likeCount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results.count > 0){
            for(Post *post in results){
                if([self livefeedContainsPost:post] == NO){
                     [self createPostBatch:post];
                 }
            }
            NSLog(@"far away batches: %@", self.individualQueues);
//            [self addToPriorityQueue:<#(NSDictionary *)#> batch:<#(NSDictionary *)#>]
        }
    }];
}

- (NSMutableDictionary *)getZipcodeBatch:(NSString *)zipcode{
    for(NSMutableDictionary *batch in self.individualQueues){
        NSString *key = batch[@"zipcode"];
        if([key isEqualToString:zipcode]) return batch;
    }
    return nil;
}

- (NSArray *)getSortedPosts:(NSArray *)dicts{
    NSMutableArray *posts = [NSMutableArray array];
    for(NSDictionary *dict in dicts){
        Post *post = dict[@"post"];
        [posts addObject:post];
    }
    return posts;
}

- (void)fetchNeighbors:(Zipcode *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion{
    [zipcode fetchIfNeededInBackgroundWithBlock:^(PFObject *zip, NSError *error){
        if(zip){
            NSArray *neighbors = zip[@"neighbors"];
            completion(neighbors, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (NSNumber *)getCreatedAtConstant:(Post *)post{
    NSDate *created = [post createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *dateStr = [dateFormat stringFromDate:created];
    NSLog(@"%@", dateStr);
    NSTimeInterval timeInterval = [created timeIntervalSince1970];
    NSLog(@"%f seconds since creation", timeInterval);
    return [NSNumber numberWithDouble:timeInterval];
}

- (void)getPostCreatedAt:(Post *)post completion:(void(^)(NSDate *createdAt, NSError *error))completion{
    [post fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error){
        if(post){
            NSDate *createdAt = post[@"createdAt"];
            completion(createdAt, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
