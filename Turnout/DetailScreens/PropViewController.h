//
//  PropViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PropDetailSegue
- (void)refreshFeed;
@end

@interface PropViewController : UIViewController
@property (nonatomic, strong) NSDictionary *prop;
@property (nonatomic, weak) id<PropDetailSegue> delegate;
@end

NS_ASSUME_NONNULL_END
