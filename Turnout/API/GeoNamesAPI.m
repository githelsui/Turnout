//
//  GeoNamesAPI.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/21/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "GeoNamesAPI.h"

static NSString * const baseURLString = @"http://api.geonames.org/";
static NSString * const username1 = @"githelsui";
static NSString * const username2 = @"githelsuico";

@interface GeoNamesAPI()

@end

@implementation GeoNamesAPI

+ (instancetype)shared {
    static GeoNamesAPI *sharedManager = nil;
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

- (void)fetchNeighbors:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion {
    NSString *parameters = [NSString stringWithFormat:@"findNearbyPostalCodesJSON?postalcode=%@&country=US&radius=30&maxRows=15&username=%@", zipcode, username2];
    NSString *fullURL = [baseURLString stringByAppendingString:parameters];
    NSLog(@"full neighbor URL: %@", fullURL);
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSError* error = nil;
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSArray *dicts = dataDictionary[@"postalCodes"];
            NSLog(@"dictionary: %@",dicts);
            completion(dicts, nil);
        }
    }];
    [task resume];
}

- (void)fetchZipInfo:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion {
    NSString *parameters = [NSString stringWithFormat:@"postalCodeLookupJSON?postalcode=%@&country=US&maxRows=1&username=%@", zipcode, username2];
    NSString *fullURL = [baseURLString stringByAppendingString:parameters];
    NSLog(@"full neighbor URL: %@", fullURL);
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSError* error = nil;
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSArray *dicts = dataDictionary[@"postalCodes"];
            NSLog(@"dictionary: %@",dicts);
            completion(dicts, nil);
        }
    }];
    [task resume];
}

- (void)fetchZipcode:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion{
    NSString *parameters = [NSString stringWithFormat:@"postalCodeLookupJSON?postalcode=%@&country=US&username=%@", zipcode, username2];
    NSString *fullURL = [baseURLString stringByAppendingString:parameters];
    NSLog(@"full neighbor URL: %@", fullURL);
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSError* error = nil;
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSArray *dicts = dataDictionary[@"postalcodes"];
            NSLog(@"dictionary: %@",dicts);
            completion(dicts, nil);
        }
    }];
    [task resume];
}

@end
