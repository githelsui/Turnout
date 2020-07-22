//
//  Zipcode.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Zipcode.h"
#import "GeocodeManager.h"

@implementation Zipcode

@dynamic zipcode;
@dynamic city;
@dynamic state;
@dynamic shortState;
@dynamic county;
@dynamic objectId;
@dynamic neighbors;
@dynamic rank;

+ (nonnull NSString *)parseClassName {
    return @"Zipcode";
}

+ (void)pregenerateZip:( NSDictionary * _Nullable )zip rank:( NSNumber * _Nullable )rank withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Zipcode *zipcode = [Zipcode new];
    zipcode.zipcode = zip[@"zipcode"];
    NSArray *neighbors = zip[@"neighbors"];
    zipcode.neighbors = [zipcode neighborArray:neighbors];
    zipcode.rank = rank;
    zipcode.city = zip[@"city"];
    zipcode.county = zip[@"county"];
    zipcode.state = zip[@"state"];
    zipcode.shortState = zip[@"shortState"];
    [zipcode saveInBackgroundWithBlock: completion];
}

+ (void)saveNewZipcode:( NSString * _Nullable )zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    [[GeocodeManager shared] fetchZipInfo:zip completion:(^ (NSArray *zipcodeData, NSError *error) {
        if (zipcodeData) {
            Zipcode *zipcode = [Zipcode new];
            NSArray *components = zipcodeData[0][@"address_components"];
            NSString *city = components[1][@"long_name"];
            NSString *county = components[2][@"long_name"];
            NSString *state = components[3][@"short_name"];
            NSLog(@"address comp! = %@", components);
            NSLog(@"city! = %@", city);
            zipcode.zipcode = zip;
            zipcode.city = city;
            zipcode.county = county;
            zipcode.state = state;
            [zipcode saveZipInUser:zipcode withCompletion:completion];
        } else {
            NSLog(@"%s", "fetchCity not working!");
        }
    })];
}

- (NSArray *)neighborArray:(NSArray *)neighbors{
    NSMutableArray *neighborObjects = [NSMutableArray array];
    for(NSDictionary *neighbor in neighbors){
        Neighbor *newNeighbor = [Neighbor createNeighbor:neighbor];
        [neighborObjects addObject:newNeighbor];
    }
    return neighborObjects;
}

- (void)saveZipInUser:(Zipcode *)zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    PFUser *currentUser = PFUser.currentUser;
    currentUser[@"zipcode"] = zip;
    [currentUser saveInBackgroundWithBlock: completion];
}

@end
