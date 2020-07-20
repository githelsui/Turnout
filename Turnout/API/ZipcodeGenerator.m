//
//  ZipcodeGenerator.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/20/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]){
    @autoreleasepool {
        NSURL *url = [NSURL fileURLWithPath:@"CSV/text/txt"];
        NSString *fileContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"file content = %@", fileContent);
    }
    return 0;
}
