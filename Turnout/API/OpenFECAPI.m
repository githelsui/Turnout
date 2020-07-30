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
       NSString *baseURLString = @"https://api.open.fec.gov/v1/candidates/?year=2020&per_page=20";
       NSString *address = [NSString stringWithFormat:@"&api_key=%@&sort_nulls_last=false&sort=name&sort_hide_null=false&candidate_status=C&sort_null_only=false&page=1", APIKey];
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


@end
