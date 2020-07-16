//
//  Zipcode.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Zipcode.h"

@implementation Zipcode

@dynamic zipcode;
@dynamic city;
@dynamic state;
@dynamic objectId;

+ (nonnull NSString *)parseClassName {
    return @"Zipcode";
}

+ (void) createZip:( NSString * _Nullable )zip withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
}

@end
