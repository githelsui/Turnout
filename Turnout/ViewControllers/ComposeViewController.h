//
//  ComposeViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposeViewController : UIViewController
@property (nonatomic, weak) id<RefreshFeedDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
