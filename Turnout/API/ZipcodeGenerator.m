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
@property (nonatomic, strong) NSMutableArray *neighborData;

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
    NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USAZipcodes" ofType:@"txt"];
    NSError *err = nil;
    NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSASCIIStringEncoding error:&err];
    NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
    NSMutableArray *mutableRows = [rows mutableCopy];
    [mutableRows removeLastObject];
    self.allData  = [self getCSVData:mutableRows];
    NSLog(@"final dicts size: %lu", (unsigned long)self.allData.count);
    [self allZipcodeNeighbors:self.allData];
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

- (void)allZipcodeNeighbors:(NSMutableArray *)readArr{
    //    for(NSDictionary *zip in readArr){
    //        NSString *zipcode = zip[@"zipcode"];
    //        if(![self containsElement:zipcode]){
    //            [self getNeighbors:zipcode];
    //        }
    //    }
    [self getNeighbors:self.allData[0][@"zipcode"]];
}

- (void)getNeighbors:(NSString *)zipcode{
    [[ZipwiseAPI shared] fetchNeighbors:zipcode completion:(^ (NSArray *neighbors, NSError *error) {
        if(neighbors){
            [self checkNeighbors:neighbors];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    })];
}

- (void)checkNeighbors:(NSArray *)neighbors{
    NSLog(@"zipcode neighbors: %@", neighbors);
    for(NSDictionary *neighbor in neighbors){
        [self.neighborData addObject:neighbor];
    }
    NSLog(@"final count after adding neighbors: %lu", (unsigned long)self.neighborData.count);
}

- (BOOL)containsElement:(NSString *)zipcode{
    for(NSDictionary *neighbor in self.neighborData){
        NSString *nei = neighbor[@"zip"];
        NSString *neighborZip = [NSString stringWithFormat:@"%@", nei];
        if([neighborZip isEqualToString:zipcode]){
            return YES;
        }
    }
    return NO;
}

@end
