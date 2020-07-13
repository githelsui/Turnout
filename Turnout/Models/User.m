//
//  User.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic username;
@dynamic zipcode;

+ (nonnull NSString *)parseClassName {
    return @"User";
}

+ (void) createUser:( NSString * _Nullable )username zipCode:( NSNumber * _Nullable)zipcode withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    User *newUser = [User new];
    newUser.username = username;
    newUser.zipcode = zipcode;
    [newUser saveInBackgroundWithBlock: completion];
}

@end
