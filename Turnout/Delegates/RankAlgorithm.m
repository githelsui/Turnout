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

static float const timeWeight = 0.005;
static float const distanceWeight = 0.00002;
static float const likesWeight = 1.75;

@interface RankAlgorithm ()
@property (nonatomic, strong) NSMutableArray *postDicts;
@property (nonatomic, strong, retain) NSMutableArray *individualQueues;
@property (nonatomic, strong, retain) Zipcode *currentZip;
@property NSInteger currentZipPosts;
@property (nonatomic, strong) PriorityQueue *queue;
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
    self.queue = [PriorityQueue new];
    self.priorityQueue = [PriorityQueue new];
    return self;
}

- (void)queryPosts:(int)skip completion:(void(^)(NSArray *posts, NSError *error))completion{
    if(skip == 0) self.currentZipPosts = 0;
    [self.neighborDicts removeAllObjects];
    [self.posts removeAllObjects];
    [self.individualQueues removeAllObjects];
    [self getCurrentUserInfo:^(NSArray *neighbors, NSError *error){
        self.neighborDicts = [neighbors mutableCopy];
        NSLog(@"final neighborDicts array: %@", neighbors);
        if(neighbors){
            [self fetchNeighboringPosts:neighbors skip:skip completion:^(NSMutableArray *individualQueues, NSError *error){
                [self fetchFarPosts:skip completion:^(NSMutableArray *individualQueues, NSError *error){
                        //fetch for non-neighboring posts for next edge case
                        [self beginMerge:self.individualQueues]; //self.individualQueues
                        [self mergeBatches];
                        completion(self.posts, nil);
                }];
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
        NSString *currZip = self.currentZip[@"zipcode"];
        NSString *lastItem = zipcodes.lastObject[@"zipcode"][@"zipcode"];
        NSLog(@"dict: %@", key);
        if([currZip isEqual:key] == NO){ //for zipcodes that are NOT current zipcode, does not matter whether refreshing/load more function
            [query setLimit:2];
            [query setSkip:skip];
        } else {
            [query setSkip:self.currentZipPosts]; //keep track of how many posts under current users zipcode, skip = self.currentZipsPosts
            //when skip == 0, refreshing functionality: reset self.currentZipsPost back to 0
        }
        [query includeKey:@"zipcode"];
        [query includeKey:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if(results.count > 0){
                NSMutableDictionary *zipcodeQueue = [[NSMutableDictionary alloc] init];
                NSNumber *loopIndex = @(0);
                [zipcodeQueue setObject:key forKey:@"zipcode"];
                [zipcodeQueue setObject:loopIndex forKey:@"loopIndex"];
                
                [self postsArrPerBatch:results zipcode:zipcode completion:^(NSMutableArray *postsArr, NSError *error){
                    [zipcodeQueue setObject:postsArr forKey:@"postsArr"];
                }];
                
                [self.individualQueues addObject:zipcodeQueue];
                if([lastItem isEqualToString:key]){
                    NSLog(@"the neighboring posts: %@", self.individualQueues);
                    completion(self.individualQueues, nil);
                }
            } else {
                if([lastItem isEqualToString:key]){
                    NSLog(@"the neighboring posts: %@", self.individualQueues);
                    completion(self.individualQueues, nil);
                }
            }
        }];
    }
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
    [query includeKey:@"likeCount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results.count > 0){
            for(Post *post in results){
                [self createPostBatch:post];
            }
            NSLog(@"far away batches: %@", self.individualQueues);
            completion(self.individualQueues, nil);
        }
    }];
}

- (void)createPostBatch:(Post *)post{
    Zipcode *zip = post[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *key = zip[@"zipcode"];
            NSMutableDictionary *batch = [self batchExists:key];
            if(batch){
                NSUInteger index = [self.individualQueues indexOfObject:batch];
                NSMutableArray *postsArr = batch[@"postsArr"];
                if([self batchContainsPost:post batch:postsArr] == NO){
//                    NSMutableDictionary *tempPost = [[NSMutableDictionary alloc] init];
//                    [tempPost setObject:@(0) forKey:@"rank"];
//                    [tempPost setObject:key forKey:@"zipcode"];
//                    [tempPost setObject:post forKey:@"post"];
//                    [postsArr addObject:tempPost];
                    NSMutableArray *updatedArr = [self addIndividualPost:post key:key postsArr:postsArr];
                    [batch setObject:updatedArr forKey:@"postsArr"];
                    [self.individualQueues replaceObjectAtIndex:index withObject:batch];
                }
            } else {
                NSMutableDictionary *farDistanceBatch = [[NSMutableDictionary alloc] init];
                [farDistanceBatch setObject:key forKey:@"zipcode"];
                NSNumber *loopIndex = @(0);
                [farDistanceBatch setObject:loopIndex forKey:@"loopIndex"];
                NSMutableArray *postsArr = [[NSMutableArray alloc] init];
                NSMutableArray *updatedArr = [self addIndividualPost:post key:key postsArr:postsArr];
                [farDistanceBatch setObject:updatedArr forKey:@"postsArr"];
                [self.individualQueues addObject:farDistanceBatch];
            }
        }
    }];
}

- (NSMutableArray *)addIndividualPost:(Post *)post key:(NSString *)key postsArr:(NSMutableArray *)postsArr{
    NSMutableArray *newArr = postsArr;
    NSMutableDictionary *tempPost = [[NSMutableDictionary alloc] init];
    [tempPost setObject:@(0) forKey:@"rank"];
    [tempPost setObject:key forKey:@"zipcode"];
    [tempPost setObject:post forKey:@"post"];
    [newArr addObject:tempPost];
    if([key isEqual:self.currentZip[@"zipcode"]]){
        self.currentZipPosts += 1;
    }
    return newArr;
}

- (BOOL)batchContainsPost:(Post *)post batch:(NSMutableArray *)batch{
    for(NSDictionary *dict in batch){
        Post *current = dict[@"post"];
        if([current isEqual:post])
            return YES;
    }
    return NO;
}

- (NSMutableDictionary *)batchExists:(NSString *)key{
    for(NSDictionary *batch in self.individualQueues){
        NSString *zipcodeStr = batch[@"zipcode"];
        if([zipcodeStr isEqualToString:key]){
            return [batch mutableCopy];
        }
    }
    return nil;
}

- (void)postsArrPerBatch:(NSArray *)posts zipcode:(NSDictionary *)zipcode completion:(void(^)(NSMutableArray *posts, NSError *error))completion{
    NSMutableArray *postsArr =  [NSMutableArray array];
    NSString *key = zipcode[@"zipcode"][@"zipcode"];
    NSString *distance = zipcode[@"distance"];
    for(Post *post in posts){
        NSMutableDictionary *tempPost = [[NSMutableDictionary alloc] init];
        NSNumber *rank = [self getPostRank:distance post:post];
        [tempPost setObject:rank forKey:@"rank"];
        [tempPost setObject:key forKey:@"zipcode"];
        [tempPost setObject:post forKey:@"post"];
        if(![self.posts containsObject:post]){
            [postsArr addObject:tempPost];
            if([key isEqual:self.currentZip[@"zipcode"]]){
                self.currentZipPosts += 1;
            }
        }
    }
    NSMutableArray *sortedArr = [[self sortPostsArr:postsArr] mutableCopy];
    NSLog(@"sorted array for %@: %@", key, sortedArr);
    completion(sortedArr, nil);
}

- (NSArray *)sortPostsArr:(NSArray *)postDicts{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:YES];
    NSArray *sortedArray = [postDicts sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedArray;
}

- (NSNumber *)getPostRank:(NSString *)distance post:(Post *)post{
    NSNumber *likes = post[@"likeCount"];
    float likeCount = [likes floatValue];
    float distWeight;
    if([distance floatValue] != 0){
        distWeight = 1 / [distance floatValue];
    } else {
        distWeight = 1 + [distance floatValue];
    }
    float rank = likeCount * distWeight;
    return @(rank);
}

- (void)beginMerge:(NSArray *)individualQueues{
    for(NSDictionary *queue in individualQueues){
        NSMutableArray *postsArr = queue[@"postsArr"];
        [self.priorityQueue add:postsArr[0]];
    }
    NSLog(@"posts inside priorityQueue: %@", self.priorityQueue);
}

- (void)mergeBatches{
    if(self.priorityQueue.size != 0) {
        NSDictionary *priorityPost = [self.priorityQueue poll];
        [self.posts addObject:priorityPost[@"post"]];
        NSString *zipcode = priorityPost[@"zipcode"];
        NSDictionary *batch = [self getZipcodeBatch:zipcode];
        NSArray *posts = batch[@"postsArr"];
        int index = [batch[@"loopIndex"] intValue] + 1;
        [batch setValue:@(index) forKey:@"loopIndex"];
        if(posts.count == index){
            [self mergeBatches];
        } else if(index < posts.count){
            [self addToPriorityQueue:posts[index] batch:batch];
        }
    } else {
        self.posts = [[[self.posts reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
}

- (void)addToPriorityQueue:(NSDictionary *)post batch:(NSDictionary *)batch{
    NSArray *posts = batch[@"postsArr"];
    int index = [batch[@"loopIndex"] intValue];
    if(posts.count != index){
        [self.priorityQueue add:post];
        [self mergeBatches];
    }
}

- (void)mergeSortForFeed{
    while(self.queue.size > 0){
        NSDictionary *queueData = [self.queue poll];
        NSLog(@"post for livefeed: %@", queueData[@"post"]);
        [self.posts addObject:queueData[@"post"]];
    }
}

- (NSDictionary *)getZipcodeBatch:(NSString *)zipcode{
    for(NSDictionary *batch in self.individualQueues){
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

- (void)getPostDictsArr:(NSArray *)posts newArr:(NSMutableArray *)newArr completion:(void(^)(NSArray *postDicts, NSError *error))completion{
    for (Post *post in posts) {
        [self calculatePostRank:post withCompletion:^(NSNumber *rank, NSError *error){
            [self createRankedDict:rank post:post withCompletion:^(NSDictionary *postDict, NSError *error){
                [newArr addObject:postDict];
                Post *lastObj = [posts lastObject];
                if([post isEqual:lastObj]){
                    completion(newArr, nil);
                }
            }];
        }];
    }
}

- (void)createRankedDict:(NSNumber *)rank post:(Post *)post withCompletion:(void(^)(NSDictionary *postDict, NSError *error))completion{
    NSMutableDictionary *tempPost = [[NSMutableDictionary alloc] init];
    [tempPost setObject:post forKey:@"post"];
    [tempPost setObject:rank forKey:@"rank"];
    completion(tempPost, nil);
}

- (void)calculatePostRank:(Post *)post withCompletion:(void(^)(NSNumber *rank, NSError *error))completion{
    NSNumber *likeCount = post.likeCount;
    PFUser *currentUser = PFUser.currentUser;
    
    Zipcode *postZipcode = post.zipcode;
    Zipcode *currentZipcode = currentUser[@"zipcode"];
    NSLog(@"zipcode for post = %@", postZipcode);
    NSLog(@"zipcode for current = %@", currentZipcode);
    
    __block NSArray *postNeighbors = nil;
    __block NSArray *currentNeighbors = nil;
    
    [self fetchNeighbors:postZipcode completion:^(NSArray *neighbors, NSError *error){
        postNeighbors = neighbors;
        NSLog(@"post neighbors for post zipcode:  %@", postNeighbors);
        [self fetchNeighbors:currentZipcode completion:^(NSArray *current, NSError *error){
            
            currentNeighbors = current;
            NSLog(@"neighbors for current zipcode:  %@", currentNeighbors);
            NSDictionary *zipInPostsNeighbors = [self checkIfAnyNeighbors:postNeighbors current:currentZipcode];
            NSDictionary *zipInCurrentNeighbors = [self checkIfAnyNeighbors:currentNeighbors current:postZipcode];
            NSLog(@"currentIsPostNeighbor:  %@", zipInCurrentNeighbors);
            NSNumber *distance;
            if(zipInPostsNeighbors){
                NSString *distanceStr = zipInPostsNeighbors[@"distance"];
                distance = @([distanceStr floatValue]);
                NSLog(@"zipinpostsneighbor:  %@", distance);
            } else if(zipInCurrentNeighbors){
                NSString *distanceStr = zipInCurrentNeighbors[@"distance"];
                distance = @([distanceStr floatValue]);
                NSLog(@"%s", "AAAAH");
            } else {
                //calc distance when neither zips are contained in each others arrays
            }
            
            NSNumber *timeSinceCreated = [self getTimeSinceCreated:post];
            NSNumber *rank = [self rankCalculation:distance likes:likeCount timeSinceCreation:timeSinceCreated];
            NSLog(@"rank = %@", rank);
            
            completion(rank, nil);
        }];
    }];
}

- (NSNumber *)rankCalculation:(NSNumber *)distanceNum likes:(NSNumber *)likesCount timeSinceCreation:(NSNumber *)timeSinceCreation{
    float likes = [likesCount floatValue];
    float secondsAgo = [timeSinceCreation floatValue];
    float distance = [distanceNum floatValue];
    float score = likes + likesWeight;
    float timeCreatedVal = secondsAgo * timeWeight;
    float distanceVal = distance * distanceWeight;
    float decay = timeCreatedVal + distanceVal;
    float rankFloat = decay / score;
    return [NSNumber numberWithFloat: rankFloat];
}

- (NSDictionary *)checkIfAnyNeighbors:(NSArray *)neighbors current:(Zipcode *)zipcode{
    NSString *mainZip = zipcode.zipcode;
    for(NSDictionary *neighbor in neighbors){
        NSString *neighString = neighbor[@"zipcode"];
        if([neighString isEqualToString:mainZip]){
            return neighbor;
        }
    }
    return nil;
}


- (void)getDistance{
    
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

- (void)getZipcode:(PFUser *)user completion:(void(^)(Zipcode *zipcode, NSError *error))completion {
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error){
        if(user){
            Zipcode *zip = user[@"zipcode"];
            completion(zip, error);
            
        } else {
            completion(nil, error);
        }
    }];
}

- (void)queryZipcode:(PFUser *)user completion:(void(^)(NSArray *zipcode, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"typeId" equalTo:user];
    [query includeKey:@"zipcode"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *zip, NSError *error) {
        if (zip != nil) {
            completion(zip, nil);
        } else {
            completion(nil, error);
        }
    }];
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

- (NSNumber *)getTimeSinceCreated:(Post *)post{
    NSDate *created = [post createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *dateStr = [dateFormat stringFromDate:created];
    NSLog(@"%@", dateStr);
    NSTimeInterval timeInterval = -[created timeIntervalSinceNow];
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

- (void)orderPostsByRank:(NSArray *)posts completion:(void(^)(NSArray *rankedPosts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            completion(posts, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
