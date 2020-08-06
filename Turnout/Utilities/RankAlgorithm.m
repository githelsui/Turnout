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

@interface RankAlgorithm ()
@property (nonatomic, strong) NSMutableArray *postDicts;
@property (nonatomic, strong, retain) NSMutableArray *individualQueues;
@property (nonatomic, strong, retain) Zipcode *currentZip;
@property (nonatomic, strong) PriorityQueue *priorityQueue;
@property (nonatomic) BOOL completeFetch;
@property (nonatomic, strong) NSCondition *fetchCondition;
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
    self.fetchCondition = [[NSCondition alloc] init];
    self.completeFetch = NO;
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
    [self.livefeed removeAllObjects];
    [self.individualQueues removeAllObjects];
    [self getCurrentUserInfo:^(NSArray *neighbors, NSError *error){
        self.neighborDicts = [neighbors mutableCopy];
        NSLog(@"final neighborDicts array: %@", neighbors);
        if(neighbors){
            [self fetchNeighboringPosts:neighbors skip:skip completion:^(NSMutableArray *individualQueues, NSError *error){
                if(individualQueues){
                    [self fetchFarPosts:skip completion:^(NSMutableArray *farPosts, NSError *error){
                        
                        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [self beginMerge:self.individualQueues];
                        });
                        
                        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [self mergeBatches];
                        });
                        
                        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            completion(self.posts, nil);
                        });
                            
                    }];
                }
            }];
        }
    }];
}

- (void)fetchZipcodeBatch:(Zipcode *)zipcode{
    NSMutableDictionary *batch = [self getZipcodeBatch:zipcode];
    [self checkQuery:batch];
    NSUInteger index = [self.individualQueues indexOfObject:batch];
    NSNumber* cursor = @([batch[@"totalFetched"] intValue] + 1);
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"likeCount"];
    [query whereKey:@"zipcode" equalTo:zipcode];
    [query setLimit:2];
    [query setSkip:[cursor integerValue]]; //skip the size of the zipcode batch's queue
    [query includeKey:@"zipcode"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"objectId"];
    [query includeKey:@"likeCount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results.count > 0){
            self.completeFetch = YES;
            for(Post *post in results){
                if([self postsContains:post] == NO){ //CASE 2: database is NOT empty, queue was empty -> fetch and add new posts to batch
                     [self createPostBatch:post];
                }
            }
            
            [self checkQuery:batch];
            self.completeFetch = YES;
            [self addToPriorityQueue:batch];
            
        } else { //case 4: both query & queue are empty (exhausted batch) -> merge other zipcodes
            [batch setObject:@YES forKey:@"queryEmpty"];
            [self.individualQueues replaceObjectAtIndex:index withObject:batch];
            [self.fetchCondition signal];
            [self.fetchCondition unlock];
            self.completeFetch = YES;
            [self mergeBatches];
        }
    }];
}

- (BOOL)allBatchQueryEmpty{
    for(NSMutableDictionary *batch in self.individualQueues){
        NSNumber *queryEmpty = batch[@"queryEmpty"];
        if([queryEmpty isEqual:@NO])
            return NO;
    }
    return YES;
}

- (void)beginMerge:(NSArray *)individualQueues{
    for(NSMutableDictionary *batch in [individualQueues reverseObjectEnumerator]){
        KSQueue *queue = batch[@"queue"];
        NSDictionary *first = [queue dequeue];
        [self updateIndividualBatch:batch queue:queue];
        [self.priorityQueue add:first];
    }
    NSLog(@"posts inside priorityQueue: %@", self.priorityQueue);
}

- (void)mergeBatches{
    while([self allBatchQueryEmpty] == NO){
        
        NSMutableDictionary *topPostsBatch = [self addPostToLiveFeed];
        NSNumber *queryEmpty = topPostsBatch[@"queryEmpty"];
        KSQueue *posts = topPostsBatch[@"queue"];
        NSInteger queueSize = [posts getSize];
        
        if(queueSize > 0){ //case 1 or 3: database has/does not have items, queue has items -> continue merging
            [self addToPriorityQueue:topPostsBatch];
        } else if(queueSize == 0 && [queryEmpty isEqual:@NO]){ //case 2: database has items, queue is empty -> fetch again
            //pause until callback sets complete fetch == yes
            [self.fetchCondition lock];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while(!self.completeFetch){
                    [NSThread sleepForTimeInterval:0.1];
                    NSLog(@"we waitin");
                }
            });
            
            [self fetchZipcodeBatch:topPostsBatch[@"zipcode"]];
            
            [self.fetchCondition unlock];
            self.completeFetch = NO;
        }
    }
}

- (NSMutableDictionary *)addPostToLiveFeed{
    NSDictionary *priorityPost = [self.priorityQueue poll];
    [self.posts addObject:priorityPost[@"post"]];
    Zipcode *zip = priorityPost[@"zipcode"];
    NSMutableDictionary *batch = [self getZipcodeBatch:zip];
    NSLog(@"post in livefeed: %@" , priorityPost[@"post"]);
    return batch;
}

- (void)addToPriorityQueue:(NSMutableDictionary *)batch{
    KSQueue *queue = batch[@"queue"];
    NSDictionary *firstElement = [queue dequeue];
    [self updateIndividualBatch:batch queue:queue];
    [self.priorityQueue add:firstElement];
    [self mergeBatches];
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
        Zipcode *zipObj = zipcode[@"zipcode"];
        NSString *key = zipObj[@"zipcode"];
        NSString *lastItem = zipcodes.lastObject[@"zipcode"][@"zipcode"];
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        [query orderByDescending:@"likeCount"];
        [query whereKey:@"zipcode" equalTo:zipcode[@"zipcode"]];
        [query setLimit:2];
        [query setSkip:skip];
        [query includeKey:@"zipcode"];
        [query includeKey:@"objectId"];
        [query includeKey:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if(results.count > 0){
                NSMutableDictionary *batch = [[NSMutableDictionary alloc] init];
                [batch setObject:zipObj forKey:@"zipcode"];
                
                [self queuePerBatch:results zipcode:zipcode completion:^(KSQueue *posts, NSError *error){
                    [batch setObject:posts forKey:@"queue"];
                    NSNumber *totalFetched = @([posts getSize]);
                    [batch setObject:totalFetched forKey:@"totalFetched"];
                }];
                
                
                if([batch[@"queue"] getSize] == 0){
                    [batch setObject:@YES forKey:@"queryEmpty"];
                } else {
                    [batch setObject:@NO forKey:@"queryEmpty"];
                }
                
                [self.individualQueues addObject:batch];
                if([lastItem isEqualToString:key]){
                    NSLog(@"the neighboring posts 1: %@", self.individualQueues);
                    completion(self.individualQueues, nil);
                }
            } else {
                if([lastItem isEqualToString:key]){
                    NSLog(@"the neighboring posts 2: %@", self.individualQueues);
                    completion(self.individualQueues, nil);
                }
            }
        }];
    }
}

- (void)queuePerBatch:(NSArray *)posts zipcode:(NSDictionary *)zipcode completion:(void(^)(KSQueue *posts, NSError *error))completion{
    KSQueue *queue = [[KSQueue alloc] init];
    Zipcode *zip = zipcode[@"zipcode"];
    NSString *distance = zipcode[@"distance"];
    for(Post *post in posts){
        NSMutableDictionary *postValues = [[NSMutableDictionary alloc] init];
        NSNumber *likes = post[@"likeCount"];
        NSNumber *rank = @([likes floatValue] * [distance floatValue]);
        [postValues setObject:rank forKey:@"rank"];
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
            NSMutableDictionary *batch = [self getZipcodeBatch:zip];
            if(batch){
                NSUInteger index = [self.individualQueues indexOfObject:batch];
                KSQueue *queue = batch[@"queue"];
                if([queue contains:post] == NO){
                    NSNumber *totalFetchedBefore = batch[@"totalFetched"];
                    NSNumber *totalFetched = @([totalFetchedBefore intValue] + 1);
                    KSQueue *updatedQueue = [self updatePostQueue:post postArr:queue];
                    [batch setObject:updatedQueue forKey:@"queue"];
                    [batch setObject:totalFetched forKey:@"totalFetched"];
                    [self.individualQueues replaceObjectAtIndex:index withObject:batch];
                }
            } else {
                NSMutableDictionary *newBatch = [[NSMutableDictionary alloc] init];
                KSQueue *queue = [[KSQueue alloc] init];
                KSQueue *updatedQueue =  [self updatePostQueue:post postArr:queue];
                NSNumber *totalFetched = @([updatedQueue getSize]);
                [newBatch setObject:totalFetched forKey:@"totalFetched"];
                [newBatch setObject:zip forKey:@"zipcode"];
                [newBatch setObject:updatedQueue forKey:@"queue"];
                if([updatedQueue getSize] == 0){
                    [newBatch setObject:@YES forKey:@"queryEmpty"];
                } else {
                    [newBatch setObject:@NO forKey:@"queryEmpty"];
                }
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

- (BOOL)postsContains:(Post *)post{
    for(Post *livepost in self.posts){
        NSString *postId = [livepost objectId];
        NSString *currentId = [post objectId];
        if([postId isEqual:currentId])
            return YES;
    }
    return NO;
}

- (int)getAllPostsInQueueSize{
    int count = 0;
    for(NSMutableDictionary *batch in self.individualQueues){
        KSQueue *queue = batch[@"queue"];
        int size = (int)[queue getSize];
        count += size;
    }
    return count;
}

- (void)updateIndividualBatch:(NSMutableDictionary *)batch queue:(KSQueue *)queue{
    NSUInteger index = [self.individualQueues indexOfObject:batch];
    [batch setObject:queue forKey:@"queue"];
    [self.individualQueues replaceObjectAtIndex:index withObject:batch];
}

- (NSMutableDictionary *)getZipcodeBatch:(Zipcode *)zipcode{
    for(NSMutableDictionary *batch in self.individualQueues){
        NSString *key = batch[@"zipcode"][@"zipcode"];
        if([key isEqualToString:zipcode[@"zipcode"]]) return batch;
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

- (void)checkQuery:(NSMutableDictionary *)batch{
    NSUInteger index = [self.individualQueues indexOfObject:batch];
    [batch setObject:@YES forKey:@"queryEmpty"];
    [self.individualQueues replaceObjectAtIndex:index withObject:batch];
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

@end
