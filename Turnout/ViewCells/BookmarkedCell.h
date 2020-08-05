//
//  BookmarkedCell.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/5/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookmarkedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideHeaderLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (nonatomic, strong) NSDictionary *bookmarkInfo;

@end

NS_ASSUME_NONNULL_END
