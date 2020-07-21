//
//  ZipwiseAPI.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/20/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ZipwiseAPI.h"

static NSString * const baseURLString = @"https://www.zipwise.com/webservices/radius.php?";
static NSString * const APIKey = @"wr4udu9y7pz3nee8";

@interface ZipwiseAPI()

@end

@implementation ZipwiseAPI

+ (instancetype)shared {
    static ZipwiseAPI *sharedManager = nil;
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
    NSString *parameters = [NSString stringWithFormat:@"key=%@&zip=%@&radius=50&format=json", APIKey, zipcode];
    NSString *fullURL = [baseURLString stringByAppendingString:parameters];
    NSLog(@"full neighbor URL: %@", fullURL);
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"zipcode error: %@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"zipcode dictionary: %@", dataDictionary);
            NSArray *dicts = dataDictionary[@"results"];
            completion(dicts, nil);
        }
    }];
    [task resume];
}

@end
