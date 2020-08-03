//
//  PropViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PropViewController.h"
#import "ProPublicaAPI.h"

@interface PropViewController ()
@property (nonatomic, strong) NSString *propId;
@end

@implementation PropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPropInfo];
    [self fetchPropDetails];
}

- (void)setPropInfo{
    self.propId = self.prop[@"bill_slug"];
}

- (void)fetchPropDetails{
    [[ProPublicaAPI shared]fetchBillInfo:self.propId completion:^(NSArray *details, NSError *error){
        if(details){
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
