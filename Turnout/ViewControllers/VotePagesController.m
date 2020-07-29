//
//  VotePagesController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/28/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VotePagesController.h"
#import <RKSwipeBetweenViewControllers/RKSwipeBetweenViewControllers.h>

@interface VotePagesController ()

@end

@implementation VotePagesController

- (void)viewDidLoad {
    [super viewDidLoad];
     UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
       
    RKSwipeBetweenViewControllers *navigationController = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
       
    UIViewController *demo = [[UIViewController alloc]init];
    UIViewController *demo2 = [[UIViewController alloc]init];
    UIViewController *demo3 = [[UIViewController alloc]init];
    UIViewController *demo4 = [[UIViewController alloc]init];
    demo.view.backgroundColor = [UIColor redColor];
    demo2.view.backgroundColor = [UIColor whiteColor];
    demo3.view.backgroundColor = [UIColor grayColor];
    demo4.view.backgroundColor = [UIColor orangeColor];
    [navigationController.viewControllerArray addObjectsFromArray:@[demo,demo2,demo3,demo4]];
    
    self.view = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view.window.rootViewController = navigationController;
    [self.view.window makeKeyAndVisible];
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
