//
//  Neighbor.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/22/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "Neighbor.h"

@implementation Neighbor

@dynamic objectId;
@dynamic zipcode;
@dynamic city;
@dynamic state;
@dynamic shortState;
@dynamic county;
@dynamic distance;

+ (nonnull NSString *)parseClassName {
    return @"Neighbor";
}

+ (Neighbor *)createNeighbor:(NSDictionary *)neighbor{
    Neighbor *newNeighbor = [Neighbor new];
    newNeighbor.zipcode = neighbor[@"zipcode"];
    newNeighbor.city = neighbor[@"city"];
    newNeighbor.state = neighbor[@"state"];
    newNeighbor.shortState = neighbor[@"shortState"];
    newNeighbor.county = neighbor[@"county"];
    NSString *distanceString = neighbor[@"distance"];
    NSNumber *distance = @([distanceString floatValue]);
    newNeighbor.distance = distance;
    return newNeighbor;
}

@end
