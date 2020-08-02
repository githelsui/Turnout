//
//  GSKExampleDataSource.h
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const NSUInteger kDefaultNumberOfRows = 100;

@interface GSKExampleDataSource : NSObject<UITableViewDataSource>

// set to true to display basic titles: "Section #X"
@property (nonatomic) BOOL displaysSectionHeaders; // default value: false
@property (nonatomic) NSUInteger numberOfSections; // default value: 1
@property (nonatomic) NSUInteger numberOfRowsInEverySection;
@property (nonatomic) NSArray<UIColor *> *cellColors;

- (instancetype)init;
- (void)registerForTableView:(UITableView *)tableView;
- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForSection:(NSInteger)section;

@end

