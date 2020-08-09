//
//  GeocodeManager.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/16/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "GeocodeManager.h"

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/geocode/json?";
static NSString * const baseDistanceURL = @" https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial";
//&origins=92806&destinations=92857&key=AIzaSyB_9yrwJD6S1XZtaQM1v9sPcTnTJ0pzRiI
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
    self = [super init];
    return self;
}

- (void)fetchDistance:(NSString *)zipcode current:(NSString *)current completion:(void(^)(NSString *distance, NSError *error))completion{
    NSString *address = [NSString stringWithFormat:@"&origins=%@&destinations=%@&key=%@", current, zipcode, APIKey];
    NSString *fullURL = [baseDistanceURL stringByAppendingString:address];
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
            NSArray *dicts = dataDictionary[@"rows"];
            NSString *distance = dicts[0][@"elements"][0][@"distance"][@"text"];
            NSString *final = [self getDistance:distance];
            completion(final, nil);
        }
    }];
    [task resume];
}

- (NSString *)getDistance:(NSString *)str{
    NSString *newDist = @"";
    NSArray *string = [str componentsSeparatedByString: @" "];
    for(NSString *digit in string){
        NSString *firstDigit = [digit substringWithRange:NSMakeRange(0, 1)];
        if([firstDigit isEqualToString:@"m"])
            break;
        else {
            newDist = [newDist stringByAppendingString:firstDigit];
        }
    }
    return newDist;
}

- (void)fetchZipInfo:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion {
    NSString *address = [NSString stringWithFormat:@"address=%@&sensor=false", zipcode];
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
            NSArray *dicts = dataDictionary[@"results"];
            completion(dicts, nil);
        }
    }];
    [task resume];
}

- (void)pregenZip:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion {
    NSString *address = [NSString stringWithFormat:@"address=%@&sensor=false", zipcode];
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
            NSArray *dicts = dataDictionary[@"results"];
            completion(dicts, nil);
        }
    }];
    [task resume];
}

@end
