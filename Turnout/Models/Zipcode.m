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

- (void)saveZipInUser:(Zipcode *)zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    PFUser *currentUser = PFUser.currentUser;
    currentUser[@"zipcode"] = zip;
    [currentUser saveInBackgroundWithBlock: completion];
}

@end
