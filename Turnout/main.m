//
//  main.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        NSMutableArray *allData = [NSMutableArray array];
        NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USAZipcodes" ofType:@"txt"];
        NSError *err = nil;
        NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSASCIIStringEncoding error:&err];
        NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
        NSMutableArray *mutableRows = [rows mutableCopy];
        [mutableRows removeLastObject];
        for(NSString *row in mutableRows){
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
        NSLog(@"final array size: %lu", (unsigned long)allData.count);
        
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

void getNeighbors(){
    
}
