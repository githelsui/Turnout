//
//  GSKExampleDataSource.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "GSKExampleDataSource.h"
#import "PostCell.h"

@interface GSKExampleDataSource ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<NSNumber *> *rowHeights;
@end

@interface GSKAirbnbSectionTitleView: UICollectionReusableView
@property (nonatomic) UILabel *label;
@end

@implementation GSKExampleDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _displaysSectionHeaders = false;
        _numberOfSections = 1;
        _numberOfRowsInEverySection = kDefaultNumberOfRows;
        [self updateRowHeights];
        self.cellColors = @[[UIColor grayColor], [UIColor lightGrayColor]];
    }
    return self;
}

- (void)setNumberOfRowsInEverySection:(NSUInteger)numberOfRowsInEverySection {
    _numberOfRowsInEverySection = numberOfRowsInEverySection;
    [self updateRowHeights];
}

- (void)registerForTableView:(UITableView *)tableView {
    _scrollView = tableView;
    
    tableView.dataSource = self;
    [PostCell registerIn:tableView];
}

- (void)updateRowHeights {
    self.rowHeights = [NSMutableArray arrayWithCapacity:self.numberOfRowsInEverySection];
    for (NSUInteger i = 0; i < self.numberOfRowsInEverySection; ++i) {
        CGFloat height = 40 + arc4random_uniform(160);
        [self.rowHeights addObject:@(height)];
    }
}

#pragma mark - table view

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRowsInEverySection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:[PostCell reuseIdentifier]];
    cell.contentView.backgroundColor = self.cellColors[indexPath.row % self.cellColors.count];
    return cell;
}

#pragma mark - generic

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.rowHeights[indexPath.item] floatValue];
}

- (NSString *)titleForSection:(NSInteger)section {
    return self.displaysSectionHeaders ? [NSString stringWithFormat:@"Section #%@", @(section)] : nil;
}

@end


@implementation GSKAirbnbSectionTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.label];
        
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

@end


