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
    self.neighborhoods = [NSMutableArray array];
    NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USAZipcodes" ofType:@"txt"];
    NSError *err = nil;
    NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSASCIIStringEncoding error:&err];
    NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
    NSMutableArray *mutableRows = [rows mutableCopy];
    
    //cap to size 10
    NSRange range;
    range.location = 0;
    range.length = 10;
    [mutableRows removeLastObject];
    NSMutableArray *tempArr = [[mutableRows subarrayWithRange:range] mutableCopy];
    self.allData  = [self getCSVData:tempArr];
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
            dict[@"shortState"] = [columns[4] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"state"] = [columns[3] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            removeQuotes = [columns[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"city"] = [removeQuotes stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            dict[@"zipcode"] = columns[1];
        }
        [allData addObject:dict];
    }
    return allData;
}

- (void)allZipcodeNeighbors{
    NSDictionary *zipcode = self.allData[0];
    [self getNeighbors:zipcode];
}

- (void)getNeighbors:(NSDictionary *)zipcode{
    NSString *zipString = zipcode[@"zipcode"];
    NSLog(@"LOOP INDEX: %lu", (unsigned long)self.loopIndex);
    if(self.loopIndex != self.allData.count){
        [[GeoNamesAPI shared] fetchNeighbors:zipString completion:(^ (NSArray *neighbors, NSError *error) {
            if(neighbors){
                NSArray *neighborhood = [self getNeighborhood:neighbors];
                NSDictionary *zipToSave = [self getZipcode:zipcode neighbors:neighborhood];
                [self.neighborhoods addObject:zipToSave];
                self.loopIndex += 1;
                if(self.loopIndex != self.allData.count) [self getNeighbors:self.allData[self.loopIndex]];
                else {
                    NSLog(@"ALL NEIGHBORHOODS method 1: %@", self.neighborhoods);
                    [self saveZipcodesInParse];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        })];
    }
}

- (NSArray *)getNeighborhood:(NSArray *)neighbors{
    NSMutableArray *neighborhood = [NSMutableArray array];
    for(NSDictionary *neighbor in neighbors){
        NSDictionary *newNeighbor = [self getNeighborZip:neighbor];
        [neighborhood addObject:newNeighbor];
    }
    NSArray *immutableNeighbor = [neighborhood copy];
    return immutableNeighbor;
}

- (NSDictionary *)getNeighborZip:(NSDictionary *)zipcode{
    NSMutableDictionary *zip = [NSMutableDictionary new];
    [zip setObject:zipcode[@"postalCode"]
            forKey:@"zipcode"];
    [zip setObject:zipcode[@"adminCode1"]
            forKey:@"shortState"];
    [zip setObject:zipcode[@"adminName2"]
            forKey:@"county"];
    [zip setObject:zipcode[@"placeName"]
            forKey:@"city"];
    [zip setObject:zipcode[@"distance"]
            forKey:@"distance"];
    return zip;
}

- (NSDictionary *)getZipcode:(NSDictionary *)zipcode neighbors:(NSArray *)neighbors{
    NSMutableDictionary *zip = [NSMutableDictionary new];
    [zip setObject:neighbors forKey:@"neighbors"];
    [zip setObject:zipcode[@"zipcode"] forKey:@"zipcode"];
    [zip setObject:zipcode[@"city"] forKey:@"city"];
    [zip setObject:zipcode[@"county"] forKey:@"county"];
    [zip setObject:zipcode[@"state"] forKey:@"state"];
    [zip setObject:zipcode[@"shortState"] forKey:@"shortState"];
    return zip;
}

- (void)saveZipcodesInParse{
    int rankInt = 1;
    for(NSDictionary *zipcode in self.neighborhoods){
        NSNumber *rank = [NSNumber numberWithInt:rankInt];
        [Zipcode pregenerateZip:zipcode rank:rank withCompletion:^(BOOL succeeded, NSError *error){
            if(!error){
                NSLog(@"%s", "able to save zipcode to parse");
            }
        }];
        rankInt += 1;
    }
}



@end
