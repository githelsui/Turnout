//
//  GoogleCivicAPI.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleCivicAPI : AFURLSessionManager

+ (instancetype)shared;

- (void)fetchVoterInfo:(NSString *)zipcode completion:(void(^)(NSArray *info, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
