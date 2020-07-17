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
@property (nonatomic, strong) NSString *state;

+ (void) createZip:( NSString * _Nullable )zip withCompletion: (PFBooleanResultBlock  _Nullable)completion;
- (void)getCityAndState;

@end

NS_ASSUME_NONNULL_END
