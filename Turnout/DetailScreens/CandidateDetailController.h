//
//  CandidateDetailController.h
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CandidateDetailDelegate
- (void)refreshFeed;
@end

@interface CandidateDetailController : UIViewController
@property (nonatomic, strong) NSDictionary *candidate;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, weak) id<CandidateDetailDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
