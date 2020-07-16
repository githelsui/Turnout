//
//  GeocodeManager.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/16/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeocodeManager : AFURLSessionManager

+ (instancetype)shared;

- (void)fetchCity:(NSString *)zipcode completion:(void(^)(NSArray *zipcodeData, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
