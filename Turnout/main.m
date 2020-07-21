//
//  main.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ZipwiseAPI.h"

NSMutableArray* getCSVData(NSMutableArray* readArr);
void getNeighbors(NSString *zipcode);
void allZipcodeNeighbors(NSMutableArray* readArr);
void checkNeighbors(NSArray *neighbors);
NSMutableArray *allData;

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USAZipcodes" ofType:@"txt"];
        NSError *err = nil;
        NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSASCIIStringEncoding error:&err];
        NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
        NSMutableArray *mutableRows = [rows mutableCopy];
        [mutableRows removeLastObject];
        allData  = getCSVData(mutableRows);
        NSLog(@"final dicts size: %lu", (unsigned long)allData.count);
        allZipcodeNeighbors(allData);
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

NSMutableArray* getCSVData(NSMutableArray* readArr){
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

void allZipcodeNeighbors(NSMutableArray* readArr){
    NSString *zip = readArr[0][@"zipcode"];
    getNeighbors(zip);
}

void getNeighbors(NSString *zipcode){
    [[ZipwiseAPI shared] fetchNeighbors:zipcode completion:(^ (NSArray *neighbors, NSError *error) {
        if(neighbors){
            checkNeighbors(neighbors);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    })];
}

void checkNeighbors(NSArray *neighbors){
    for(NSDictionary *neighbor in neighbors){
        for(NSDictionary *zip in allData){
            NSString *neighborZip = neighbor[@"zipcode"];
            const char *neighborChar = [neighborZip UTF8String];
            NSString *mainZip = zip[@"zipcode"];
            const char *mainChar = [mainZip UTF8String];
            if(strcmp(neighborChar, mainChar) == 0){
                [allData removeObject:zip];
            }
        }
    }
    NSLog(@"final count after removing neighbors: %lu", (unsigned long)allData.count);
}
