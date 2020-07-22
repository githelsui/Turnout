//
//  ZipcodeGenerator.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/20/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipwiseAPI.h"
#import "GeoNamesAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZipcodeGenerator : AFURLSessionManager

+ (instancetype)shared;

- (void)generateZipcodes;

@end

NS_ASSUME_NONNULL_END
