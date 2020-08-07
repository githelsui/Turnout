//
//  CommentViewController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CommentDelegate
- (void)refreshComments;
@end

@interface CommentViewController : UIViewController
@property (nonatomic, strong) Post *post;
@property (nonatomic, weak) id<CommentDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
