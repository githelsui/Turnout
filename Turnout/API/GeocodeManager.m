//
//  GeocodeManager.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/16/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "GeocodeManager.h"

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/geocode/json?";
static NSString * const APIKey = @"AIzaSyB_9yrwJD6S1XZtaQM1v9sPcTnTJ0pzRiI";
static NSString * const consumerSecret = @"s5ynGqXzstUZwFPxVyMDkYh197qvHOcVM3kwv1o2TKhS1avCdS";

@interface GeocodeManager()

@end

@implementation GeocodeManager

+ (instancetype)shared {
    static GeocodeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    //    self = [super initWithBaseURL:url];
    self = [super init];
    return self;
}

//http://maps.googleapis.com/maps/api/geocode/json?address={zipcode}&sensor=false&key=APIKEY
- (void)fetchCity:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion {
    NSString *address = [NSString stringWithFormat:@"address=%@&senor=false", zipcode];
    NSString *firstURL = [baseURLString stringByAppendingString:address]; // returns https://maps.googleapis.com/maps/api/geocode/json?address={zipcode}&sensor=false
    NSString *secondURL = [NSString stringWithFormat:@"&key=%@", APIKey];
    NSString *fullURL = [firstURL stringByAppendingString:secondURL];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *dictionaries = dataDictionary[@"results"];
            NSLog(@"%@", dictionaries);
            completion(dictionaries, nil);
        }
    }];
    [task resume];
}

@end
