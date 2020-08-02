//
//  GSKExampleData.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSKExampleData : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nullable, nonatomic, readonly) Class viewControllerClass;
@property (nullable, nonatomic, readonly) Class headerViewClass;
@property (nullable, nonatomic, readonly) NSString *nibName;
@property (nonatomic) BOOL navigationBarVisible; // default NO
@property (nonatomic) CGFloat headerViewInitialHeight; // default 240

+ (instancetype)dataWithTitle:(NSString *)title
              headerViewClass:(Class)headerViewClass;
+ (instancetype)dataWithTitle:(NSString *)title
            headerViewNibName:(NSString *)nibName;
+ (instancetype)dataWithTitle:(NSString *)title
          viewControllerClass:(Class)viewControllerClass;

@end

NS_ASSUME_NONNULL_END

