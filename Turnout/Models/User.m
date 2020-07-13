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
@dynamic password;

+ (nonnull NSString *)parseClassName {
    return @"User";
}

+ (void) createUser:( NSString * _Nullable )username password:( NSString * _Nullable)password withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    User *newUser = [User new];
    newUser.username = username;
    newUser.password = password;
    [newUser saveInBackgroundWithBlock: completion];
}

@end
