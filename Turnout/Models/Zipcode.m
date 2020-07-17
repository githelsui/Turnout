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
@dynamic objectId;

+ (nonnull NSString *)parseClassName {
    return @"Zipcode";
}

+ (void)createZip:( NSString * _Nullable )zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
}

- (void)getCityAndState{
    [[GeocodeManager shared] fetchCity:self.zipcode completion:(^ (NSArray *zipcodeData, NSError *error) {
        if (zipcodeData) {
            NSLog(@"%@", zipcodeData);
        } else {
           NSLog(@"%s", "fetchCity working!");
        }
    })];
}

@end
