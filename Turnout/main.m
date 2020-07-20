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
        // Setup code that might create autoreleased objects goes here.
        NSMutableArray *allData = [NSMutableArray array];
        NSString *myPath = [[NSBundle mainBundle]pathForResource:@"USZipcodes" ofType:@"txt"];
        NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Our file contains this: %@", myPath);
        NSArray *rows = [myFile componentsSeparatedByString:@"\n"];
        for(NSString *row in rows){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray* columns = [row componentsSeparatedByString:@","];
            dict[@"zipcode"] = columns[1];
            dict[@"city"] = columns[2];
            [allData addObject:dict];
        }
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
