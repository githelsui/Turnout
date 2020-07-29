//
//  VotePagesController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/28/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VotePagesController.h"
#import "RKSwipeBetweenViewControllers.h"

@interface VotePagesController ()

@end

@implementation VotePagesController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)viewWillAppear:(BOOL)animated{
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
         
      RKSwipeBetweenViewControllers *navigationController = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
         
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
      
      UIViewController *demo = [storyboard instantiateViewControllerWithIdentifier:@"VoteLinksViewController"];
      UIViewController *demo2 = [storyboard instantiateViewControllerWithIdentifier:@"VoteInfoViewController"];
      [navigationController.viewControllerArray addObjectsFromArray:@[demo,demo2]];
      
//    [self.view addSubview:pageController];
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
