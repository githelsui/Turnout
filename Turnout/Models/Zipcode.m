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

+ (Zipcode *)createZip:(NSString * _Nullable )zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Zipcode *newZip = [Zipcode new];
    newZip.zipcode = zip;
    [self getZipcodeInfo:zip];
    newZip.city = [newZip getCity];
    //    newZip.county = county;
    //    newZip.state = state;
    [newZip saveInBackgroundWithBlock: completion];
    return newZip;
}

+ (void)getZipcodeInfo:( NSString * _Nullable )zip{
    [[GeocodeManager shared] fetchZipInfo:zip completion:(^ (NSArray *zipcodeData, NSError *error) {
        if (zipcodeData) {
            addressComps = zipcodeData[0][@"address_components"];
            //            NSString *city = components[1][@"long_name"];
            //            NSString *county = components[2][@"long_name"];
            //            NSString *state = components[3][@"long_name"];
            NSLog(@"zipcode.m = %@", zipcodeData);
            //            NSLog(@"address comp! = %@", components);
        } else {
            NSLog(@"%s", "fetchCity not working!");
        }
    })];
}

- (NSString *)getCity{
    return addressComps[1][@"long_name"];
}

- (NSString *)getCounty{
    return addressComps[2][@"long_name"];
}

- (NSString *)getState{
    return addressComps[3][@"long_name"];
}

@end
