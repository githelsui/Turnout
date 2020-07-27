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

static float const timeWeight = 0.005;
static float const distanceWeight = 0.00002;
static float const likesWeight = 1.75;

@interface RankAlgorithm ()
@property (nonatomic, strong) NSMutableArray *postDicts;

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
    return self;
}

- (void)queryPosts:(void(^)(NSArray *rankedPosts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"Zipcode"];
    [query includeKey:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(results){
            NSMutableArray *dictsArr = [NSMutableArray array];
            [self getPostDictsArr:results newArr:dictsArr completion:^(NSArray *postDicts, NSError *error){
                NSLog(@"postDicts = %@", postDicts);
                NSArray *sortedDicts = [self sortPostDicts:postDicts];
                NSLog(@"sortedDicts = %@", sortedDicts);
                NSArray *rankedPosts = [self getSortedPosts:sortedDicts];
                NSLog(@"rankedPosts = %@", rankedPosts);
                completion(rankedPosts, error);
            }];
        }
    }];
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

- (NSArray *)sortPostDicts:(NSArray *)postDicts{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:YES];
    NSArray *sortedArray = [postDicts sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedArray;
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
