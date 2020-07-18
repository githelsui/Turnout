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
@dynamic county;
@dynamic objectId;
NSArray *addressComps;

+ (nonnull NSString *)parseClassName {
    return @"Zipcode";
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

- (void)saveZipInUser:(Zipcode *)zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    PFUser *currentUser = PFUser.currentUser;
    currentUser[@"zipcode"] = zip;
    [currentUser saveInBackgroundWithBlock: completion];
}

@end
