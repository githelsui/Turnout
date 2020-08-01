//
//  GoogleCivicAPI.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "GoogleCivicAPI.h"

static NSString * const baseURLString = @"https://www.googleapis.com/civicinfo/v2";
static NSString * const APIKey = @"AIzaSyB_9yrwJD6S1XZtaQM1v9sPcTnTJ0pzRiI";
static NSString * const consumerSecret = @"s5ynGqXzstUZwFPxVyMDkYh197qvHOcVM3kwv1o2TKhS1avCdS";

@implementation GoogleCivicAPI

+ (instancetype)shared {
    static GoogleCivicAPI *sharedManager = nil;
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

- (void)fetchElections:(void(^)(NSArray *info, NSError *error))completion{
       NSString *address = [NSString stringWithFormat:@"/elections?key=%@", APIKey];
       NSString *fullURL = [baseURLString stringByAppendingString:address];
       NSLog(@"full URL: %@", fullURL);
       NSURL *url = [NSURL URLWithString:fullURL];
       NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
       NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
           if (error) {
               NSLog(@"zipcode error: %@", [error localizedDescription]);
               completion(nil, error);
           } else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"data dictionary: %@", dataDictionary);
               NSArray *elections = dataDictionary[@"elections"];
               completion(elections, nil);
           }
       }];
       [task resume];
}

- (void)fetchElectionDetails:(NSString *)zipcode election:(NSString *)election completion:(void(^)(NSMutableDictionary *info, NSError *error))completion{
       NSString *address = [NSString stringWithFormat:@"/voterinfo?address=%@&electionId=%@&returnAllAvailableData=true&key=%@", zipcode, election, APIKey];
       NSString *fullURL = [baseURLString stringByAppendingString:address];
       NSLog(@"full URL: %@", fullURL);
       NSURL *url = [NSURL URLWithString:fullURL];
       NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
       NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
           if (error) {
               NSLog(@"zipcode error: %@", [error localizedDescription]);
               completion(nil, error);
           } else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSMutableDictionary *contentType =  [[NSMutableDictionary alloc] init];
               if([self hasContests:dataDictionary] == YES){
                   [contentType setObject:@"contest" forKey:@"contentType"];
                   NSArray *returnArr = [self getContests:dataDictionary];
                   [contentType setObject:returnArr forKey:@"details"];
                   NSLog(@"dictionary: %@", contentType);
                   completion(contentType, nil);
               } else {
                   [contentType setObject:@"noContest" forKey:@"contentType"];
                   NSString *name = dataDictionary[@"election"][@"name"];
                   NSString *state = [self getState:name];
                   [self fetchVoterInfo:state completion:^(NSArray *info, NSError *error){
                       [contentType setObject:info forKey:@"details"];
                       completion(contentType, nil);
                   }];
               }
           }
       }];
       [task resume];
}

- (void)fetchVoterInfo:(NSString *)zipcode completion:(void(^)(NSArray *info, NSError *error))completion{
    NSString *address = [NSString stringWithFormat:@"/voterinfo?key=%@&address=%@&electionId=2000&returnAllAvailableData=true", APIKey, zipcode];
    NSString *fullURL = [baseURLString stringByAppendingString:address];
    NSLog(@"full URL: %@", fullURL);
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"data dictionary: %@", dataDictionary);
            NSArray *newArr = [self getNoContests:dataDictionary];
            NSLog(@"new array from vote api: %@", newArr);
            completion(newArr, nil);
        }
    }];
    [task resume];
}

- (NSString *)createAddress:(NSDictionary *)dict{
    NSString *newAddress = @"";
    NSString *city = [NSString stringWithFormat:@" %@, ", dict[@"city"]];
    NSString *street = dict[@"line1"];
    NSString *state = [NSString stringWithFormat:@"%@", dict[@"state"]];
    NSString *zip = [NSString stringWithFormat:@" %@", dict[@"zip"]];
    newAddress = [newAddress stringByAppendingString:street];
    newAddress = [newAddress stringByAppendingString:city];
    newAddress = [newAddress stringByAppendingString:state];
    newAddress = [newAddress stringByAppendingString:zip];
    return newAddress;
}

- (BOOL)hasContests:(NSDictionary *)results{
    NSArray *contests = results[@"contests"];
    if(contests.count > 0){
        return YES;
    } else {
        return NO;
    }
}

- (NSArray *)getContests:(NSDictionary *)results{
    NSArray *contests = results[@"contests"];
    NSMutableArray *updatedContests = [NSMutableArray array];
    for(NSDictionary *contest in contests){
        NSMutableDictionary *newContest = [self getContest:contest];
        [updatedContests addObject:newContest];
    }
    return updatedContests;
}

- (NSMutableDictionary *)getContest:(NSDictionary *)contest{
    NSMutableDictionary *newCont = [[NSMutableDictionary alloc] init];
    NSString *type = contest[@"type"];
    [newCont setObject:type forKey:@"type"];
    if([type isEqualToString:@"General"]){
        [newCont setObject:contest[@"office"] forKey:@"office"];
        [newCont setObject:contest[@"candidates"] forKey:@"candidates"];
    } else if([type isEqualToString:@"Referendum"]){
        [newCont setObject:contest[@"referendumTitle"] forKey:@"office"];
        [newCont setObject:contest[@"referendumSubtitle"] forKey:@"description"];
        [newCont setObject:contest[@"referendumUrl"] forKey:@"url"];
        
    }
    return newCont;
}

- (NSArray *)getNoContests:(NSDictionary *)results{
    NSDictionary *dicts = results[@"state"][0];
    NSDictionary *electionAdmin = dicts[@"electionAdministrationBody"];
    NSMutableArray *newArr = [NSMutableArray array];
    NSMutableDictionary *electionInfo = [NSMutableDictionary new];
    [electionInfo setObject:@"Election Information" forKey:@"title"];
    [electionInfo setObject:electionAdmin[@"electionInfoUrl"] forKey:@"url"];
    [electionInfo setObject:electionAdmin[@"name"] forKey:@"desc"];
    [electionInfo setObject:@"voteInfo" forKey:@"type"];
    [newArr addObject:electionInfo];
    NSMutableDictionary *votingLocation = [NSMutableDictionary new];
    [votingLocation setObject:@"Voting Locations" forKey:@"title"];
    [votingLocation setObject:electionAdmin[@"votingLocationFinderUrl"] forKey:@"url"];
    [votingLocation setObject:electionAdmin[@"name"] forKey:@"desc"];
    [votingLocation setObject:@"voteInfo" forKey:@"type"];
    [newArr addObject:votingLocation];
    NSMutableDictionary *ballotInfo = [NSMutableDictionary new];
    [ballotInfo setObject:@"Ballot Information" forKey:@"title"];
    [ballotInfo setObject:electionAdmin[@"ballotInfoUrl"] forKey:@"url"];
    [ballotInfo setObject:electionAdmin[@"name"] forKey:@"desc"];
    [ballotInfo setObject:@"voteInfo" forKey:@"type"];
    [newArr addObject:ballotInfo];
    NSMutableDictionary *correspondanceAddress = [NSMutableDictionary new];
    [correspondanceAddress setObject:@"Correspondance Address" forKey:@"title"];
    NSString *address = [self createAddress:electionAdmin[@"correspondenceAddress"]];
    [correspondanceAddress setObject:address forKey:@"address"];
    [correspondanceAddress setObject:electionAdmin[@"name"] forKey:@"desc"];
    [correspondanceAddress setObject:@"address" forKey:@"type"];
    [newArr addObject:correspondanceAddress];
    return newArr;
}

- (NSString *)getState:(NSString *)fullName{
    NSArray *substrings = [fullName componentsSeparatedByString:@" "];
    return [substrings objectAtIndex:0];
}

@end
