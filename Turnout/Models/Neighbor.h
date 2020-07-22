//
//  Neighbor.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/22/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Neighbor : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *county;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *shortState;
@property (nonatomic, strong) NSNumber *distance;

+ (Neighbor *)createNeighbor:(NSDictionary *)neighbor;

@end

NS_ASSUME_NONNULL_END
