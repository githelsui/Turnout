//
//  OpenFECAPI.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "OpenFECAPI.h"

static NSString * const APIKey = @"SxlbqyaY2PKbvjUkyGWU8cG1FY5DwjXairvKVwYl";

@implementation OpenFECAPI

+ (instancetype)shared {
    static OpenFECAPI *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)fetchCandidates:(void(^)(NSArray *info, NSError *error))completion{
       NSString *baseURLString = @"https://api.open.fec.gov/v1/candidates/?";
       NSString *address = [NSString stringWithFormat:@"page=1&api_key=%@&sort=name&sort_nulls_last=false&is_active_candidate=true&candidate_status=C&year=2020&sort_hide_null=false&incumbent_challenge=C&per_page=20&sort_null_only=false", APIKey];
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
               NSArray *results = dataDictionary[@"results"];
               NSLog(@"before results: %@", results);
               NSArray *candidates = [self createCandidateArr:results];
               NSLog(@"array results: %@", candidates);
               completion(candidates, nil);
           }
       }];
       [task resume];
}

- (void)fetchCandidateDetails:(NSString *)id completion:(void(^)(NSArray *info, NSError *error))completion{
    
}

- (NSArray *)createCandidateArr:(NSArray *)arr{
    NSMutableArray *candidates = [NSMutableArray array];
    for(NSDictionary *candidate in arr){
        NSDictionary *newCand = [self createCandidate:candidate];
        [candidates addObject:newCand];
    }
    return candidates;
}

- (NSDictionary *)createCandidate:(NSDictionary *)candidate{
     NSMutableDictionary *newCand = [[NSMutableDictionary alloc] init];
     [newCand setObject:candidate[@"candidate_id"] forKey:@"candidate_id"];
     [newCand setObject:candidate[@"incumbent_challenge_full"] forKey:@"candidateType"];
     NSString *office = [self getOffice:candidate[@"office"]];
     [newCand setObject:office forKey:@"office"];
     [newCand setObject:candidate[@"party_full"] forKey:@"party"];
     [newCand setObject:candidate[@"name"] forKey:@"name"];
     [newCand setObject:candidate[@"state"] forKey:@"state"];
    return newCand;
}

- (NSString *)getOffice:(NSString *)type{
    if([type isEqualToString:@"H"]) {
        return @"House of Representatives";
    }
    else if([type isEqualToString:@"S"]){
        return @"Senate";
    } else {
        return @"President";
    }
}


@end
