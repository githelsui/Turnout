//
//  Zipcode.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Zipcode.h"
#import "GeocodeManager.h"
#import "GeoNamesAPI.h"

@implementation Zipcode

@dynamic zipcode;
@dynamic city;
@dynamic state;
@dynamic shortState;
@dynamic county;
@dynamic objectId;
@dynamic neighbors;
@dynamic rank;
NSArray *neighbors;

+ (nonnull NSString *)parseClassName {
    return @"Zipcode";
}

+ (void)pregenerateZip:( NSDictionary * _Nullable )zip rank:( NSNumber * _Nullable )rank withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Zipcode *zipcode = [Zipcode new];
    zipcode.zipcode = zip[@"zipcode"];
    zipcode.neighbors = zip[@"neighbors"];
    zipcode.rank = rank;
    zipcode.city = zip[@"city"];
    zipcode.county = zip[@"county"];
    zipcode.state = zip[@"state"];
    zipcode.shortState = zip[@"shortState"];
    [zipcode saveInBackgroundWithBlock: completion];
}

+ (void)createNewZip:(NSDictionary *)zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    NSString *key = zip[@"postalcode"];
    [self getNeighbors:key completion:^(NSArray *zipcodes, NSError *error){
        Zipcode *zipcode = [Zipcode new];
        zipcode.zipcode = key;
        zipcode.neighbors = zipcodes;
        zipcode.rank = @(0);
        zipcode.city = zip[@"placeName"];
        zipcode.county = zip[@"adminName2"];
        zipcode.state = zip[@"adminName1"];
        zipcode.shortState = zip[@"adminCode1"];
        [zipcode saveZipInUser:zipcode withCompletion:completion];
    }];
}

+ (void)getNeighbors:(NSString *)zipcode completion:(void(^)(NSArray *zipcodes, NSError *error))completion{
    [[GeoNamesAPI shared] fetchNeighbors:zipcode completion:^(NSArray *neighbors, NSError *error){
        if(neighbors.count > 0){
            NSMutableArray *newNeighbors = [NSMutableArray array];
            for(NSDictionary *neighbor in neighbors){
                NSDictionary *neigh = [self getNeighborZip:neighbor];
                [newNeighbors addObject:neigh];
            }
            completion(newNeighbors, nil);
        } else {
            completion(nil, error);
        }
    }];
}

+ (NSDictionary *)getNeighborZip:(NSDictionary *)zipcode{
    NSMutableDictionary *zip = [NSMutableDictionary new];
    [zip setObject:zipcode[@"postalCode"]
            forKey:@"zipcode"];
    [zip setObject:zipcode[@"adminName1"]
            forKey:@"state"];
    [zip setObject:zipcode[@"adminCode1"]
            forKey:@"shortState"];
    [zip setObject:zipcode[@"adminName2"]
            forKey:@"county"];
    [zip setObject:zipcode[@"placeName"]
            forKey:@"city"];
    [zip setObject:zipcode[@"distance"]
            forKey:@"distance"];
    return zip;
}

- (void)saveZipInUser:(Zipcode *)zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    PFUser *currentUser = PFUser.currentUser;
    currentUser[@"zipcode"] = zip;
    [currentUser saveInBackgroundWithBlock: completion];
}

@end
