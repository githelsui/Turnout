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

//"https://www.googleapis.com/civicinfo/v2/voterinfo?key=AIzaSyB_9yrwJD6S1XZtaQM1v9sPcTnTJ0pzRiI&address=1263%20Pacific%20Ave.%20Kansas%20City%20KS&electionId=2000"

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

- (void)fetchVoterInfo:(NSString *)zipcode completion:(void(^)(NSArray *info, NSError *error))completion{
    NSString *address = [NSString stringWithFormat:@"/voterinfo?key=%@&address=%@&electionId=2000", APIKey, zipcode];
    NSString *firstURL = [baseURLString stringByAppendingString:address];
    NSString *secondURL = [NSString stringWithFormat:@"&key=%@", APIKey];
    NSString *fullURL = [firstURL stringByAppendingString:secondURL];
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
            NSDictionary *dicts = dataDictionary[@"state"][0];
            NSDictionary *electionAdmin = dicts[@"electionAdministrationBody"];
            NSMutableArray *newArr = [NSMutableArray array];
            NSMutableDictionary *electionInfo = [NSMutableDictionary new];
            [electionInfo setObject:@"Election Information" forKey:@"title"];
            [electionInfo setObject:electionAdmin[@"electionInfoUrl"] forKey:@"url"];
            [electionInfo setObject:electionAdmin[@"name"] forKey:@"desc"];
            [newArr addObject:electionInfo];
            NSMutableDictionary *votingLocation = [NSMutableDictionary new];
            [votingLocation setObject:@"Voting Locations" forKey:@"title"];
            [votingLocation setObject:electionAdmin[@"votingLocationFinderUrl"] forKey:@"url"];
            [votingLocation setObject:electionAdmin[@"name"] forKey:@"desc"];
            [newArr addObject:votingLocation];
            NSMutableDictionary *ballotInfo = [NSMutableDictionary new];
            [ballotInfo setObject:@"Ballot Information" forKey:@"title"];
            [ballotInfo setObject:electionAdmin[@"ballotInfoUrl"] forKey:@"url"];
            [ballotInfo setObject:electionAdmin[@"name"] forKey:@"desc"];
            [newArr addObject:ballotInfo];
            NSMutableDictionary *correspondanceAddress = [NSMutableDictionary new];
            [correspondanceAddress setObject:@"Correspondance Address" forKey:@"title"];
            NSString *address = [self createAddress:electionAdmin[@"correspondenceAddress"]];
            [correspondanceAddress setObject:address forKey:@"address"];
            [correspondanceAddress setObject:electionAdmin[@"name"] forKey:@"desc"];
            [newArr addObject:correspondanceAddress];
            NSLog(@"new array from vote api: %@", newArr);
            completion(newArr, nil);
        }
    }];
    [task resume];
}

- (NSString *)createAddress:(NSDictionary *)dict{
    NSString *newAddress = @"";
    for(id key in dict){
        NSString *toAdd = [dict objectForKey:key];
        newAddress = [newAddress stringByAppendingString:toAdd];
    }
    return newAddress;
}

@end
