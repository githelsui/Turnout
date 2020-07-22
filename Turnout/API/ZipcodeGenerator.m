//
//  ZipcodeGenerator.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/20/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ZipcodeGenerator.h"

@interface ZipcodeGenerator()

@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *neighborhoods;
@property (nonatomic, strong) NSMutableArray *neighborData;
@property (nonatomic) NSUInteger loopIndex;

@end

@implementation ZipcodeGenerator

+ (instancetype)shared {
    static ZipcodeGenerator *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)generateZipcodes{
    self.loopIndex = 0;
    self.neighborData = [NSMutableArray array];
    self.neighborhoods = [NSMutableArray array];
    NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USAZipcodes" ofType:@"txt"];
    NSError *err = nil;
    NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSASCIIStringEncoding error:&err];
    NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
    NSMutableArray *mutableRows = [rows mutableCopy];
    
    //cap to size 10
    NSRange range;
    range.location = 0;
    range.length = 9;
    [mutableRows removeLastObject];
    NSMutableArray *tempArr = [[mutableRows subarrayWithRange:range] mutableCopy];
    self.allData  = [self getCSVData:tempArr];
    NSLog(@"final array size: %lu", (unsigned long)self.allData.count);
    [self allZipcodeNeighbors];
}

- (NSMutableArray *)getCSVData:(NSMutableArray *) readArr{
    NSMutableArray *allData = [NSMutableArray array];
    for(NSString *row in readArr){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSArray* columns = [row componentsSeparatedByString:@","];
        for(NSString *col in columns){
            NSString *removeQuotes = [columns[5] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"county"] = [removeQuotes stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"state"] = [columns[4] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            removeQuotes = [columns[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"city"] = [removeQuotes stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"zipcode"] = columns[1];
        }
        NSLog(@"Our dictionary contains this: %@", dict);
        [allData addObject:dict];
    }
    return allData;
}

- (void)allZipcodeNeighbors{
    [self getNeighbors:self.allData[0][@"zipcode"]];
}

- (void)getNeighbors:(NSString *)zipcode{
    NSLog(@"LOOP INDEX: %lu", (unsigned long)self.loopIndex);
    if(self.loopIndex != self.allData.count && ![self containsElement:zipcode]){
        [[GeoNamesAPI shared] fetchNeighbors:zipcode completion:(^ (NSArray *neighbors, NSError *error) {
            if(neighbors){
                NSArray *neighborhood = [self getNeighborhood:neighbors];
                [self.neighborhoods addObject:neighborhood];
                [self checkNeighbors:neighborhood];
                self.loopIndex += 1;
                if(self.loopIndex != self.allData.count) [self getNeighbors:self.allData[self.loopIndex][@"zipcode"]];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        })];
    } else if (self.loopIndex != self.allData.count && [self containsElement:zipcode]){
        self.loopIndex += 1;
        if(self.loopIndex != self.allData.count) [self getNeighbors:self.allData[self.loopIndex][@"zipcode"]];
    }
}

- (void)checkNeighbors:(NSArray *)neighbors{
    NSLog(@"zipcode neighbors: %@", neighbors);
    for(NSDictionary *neighbor in neighbors){
        [self.neighborData addObject:neighbor];
    }
    NSLog(@"final count after adding neighbors: %lu", (unsigned long)self.neighborData.count);
}

- (NSArray *)getNeighborhood:(NSArray *)neighbors{
    NSMutableArray *neighborhood = [NSMutableArray array];
    for(NSDictionary *neighbor in neighbors){
        NSString *zipcode = neighbor[@"postalCode"];
        if(self.neighborData.count == 0){
            [neighborhood addObject:neighbor];
        }
        if(self.neighborData.count != 0 && [self containsElement:zipcode] == NO){
            [neighborhood addObject:neighbor];
        }
    }
    NSLog(@"NEIGHBORHOODS: %@", neighborhood);
    NSArray *immutableNeighbor = [neighborhood copy];
    return immutableNeighbor;
}

- (BOOL)containsElement:(NSString *)zipcode{
    for(NSDictionary *neighbor in self.neighborData){
        NSString *nei = neighbor[@"postalCode"];
        NSString *neighborZip = [NSString stringWithFormat:@"%@", nei];
        if([neighborZip isEqualToString:zipcode]){
            return YES;
        }
    }
    return NO;
}

@end
