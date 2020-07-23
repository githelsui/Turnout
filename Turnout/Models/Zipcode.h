//
//  Zipcode.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


NS_ASSUME_NONNULL_BEGIN

@interface Zipcode : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *county;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *shortState;
@property (nonatomic, strong) NSArray *neighbors;
@property (nonatomic, strong) NSNumber *rank;

+ (void)pregenerateZip:( NSDictionary * _Nullable )zip rank:( NSNumber * _Nullable )rank withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void)saveNewZipcode:( NSString * _Nullable )zip withCompletion:(void(^)(NSArray *zipcodeData, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
