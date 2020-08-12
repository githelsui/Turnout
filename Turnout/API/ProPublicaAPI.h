//
//  ProPublicaAPI.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProPublicaAPI : AFURLSessionManager

+ (instancetype)shared;
- (void)fetchHouseBills:(void(^)(NSArray *info, NSError *error))completion;
- (void)fetchBillInfo:(NSString *)billId completion:(void(^)(NSArray *info, NSError *error))completion;
- (void)fetchCandidates:(NSString *)state completion:(void(^)(NSArray *info, NSError *error))completion;
- (void)fetchSpecificCand:(NSString *)candID completion:(void(^)(NSDictionary *info, NSError *error))completion;
- (void)fetchDistrict:(NSString *)endpoint completion:(void(^)(NSDictionary *info, NSError *error))completion;
- (void)fetchCommittee:(NSString *)endpoint completion:(void(^)(NSDictionary *info, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
