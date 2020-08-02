//
//  ProfileTableView.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/1/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ProfileTableView.h"
#import "UINavigationController+Transparency.h"

@interface ProfileTableView ()

@end

@implementation ProfileTableView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = [self defaultTitle];
    }
    return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    UIEdgeInsets contentInset = self.tableView.contentInset;
    if (self.navigationController) {
        contentInset.top = 64;
    }
    if (self.tabBarController) {
        contentInset.bottom = 44;
    }
    self.tableView.contentInset = contentInset;

    _stretchyHeaderView = [self loadStretchyHeaderView];
    [self.tableView addSubview:self.stretchyHeaderView];

    _dataSource = [self loadDataSource];
    [self.dataSource registerForTableView:self.tableView];
}

- (GSKExampleDataSource *)loadDataSource {
    return [[GSKExampleDataSource alloc] init];
}

- (NSString *)defaultTitle {
    NSString *className = NSStringFromClass(self.class);
    NSString *lastComponent = [className componentsSeparatedByString:@"."].lastObject;
    NSString *title = [lastComponent stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@"Example" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@"GSK" withString:@""];
    return title;
}

- (GSKStretchyHeaderView *)loadStretchyHeaderView {
    NSAssert(NO, @"please override %@", NSStringFromSelector(_cmd));
    return nil;
}

#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
