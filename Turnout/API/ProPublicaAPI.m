//
//  ProPublicaAPI.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProPublicaAPI.h"

static NSString * const APIKey = @"elt4Im3mCpULdzVEZrnB9oI38gJEwkRKf9pjzvNB";

@implementation ProPublicaAPI

+ (instancetype)shared {
    static ProPublicaAPI *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)fetchHouseBills:(void(^)(NSArray *info, NSError *error))completion{
    NSURL *url2 = [NSURL URLWithString:@"https://api.propublica.org/congress/v1/bills/upcoming/house.json"];
    NSURLSession *session = [NSURLSession sharedSession];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url2];

    [request setHTTPMethod:@"GET"];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:APIKey forHTTPHeaderField:@"X-API-Key"];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *results = dataDictionary[@"results"][0];
            NSArray *bills = results[@"bills"];
            NSLog(@"propublica bills: %@", bills);
            completion(bills, nil);
        }
    }];
    [task resume];
}

- (void)fetchBillInfo:(NSString *)billId completion:(void(^)(NSArray *info, NSError *error))completion{
    NSString *baseURL = [NSString stringWithFormat: @"https://api.propublica.org/congress/v1/116/bills/%@.json", billId];
    NSURL *url2 = [NSURL URLWithString:baseURL];
    NSURLSession *session = [NSURLSession sharedSession];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url2];

    [request setHTTPMethod:@"GET"];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:APIKey forHTTPHeaderField:@"X-API-Key"];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *results = dataDictionary[@"results"];
            NSLog(@"propublica bills: %@", results);
            completion(results, nil);
        }
    }];
    [task resume];
}

@end
