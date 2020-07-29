//
//  VoteLinksViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/28/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VoteLinksViewController.h"

@interface VoteLinksViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkRegistrationBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *absenteeBtn;

@end

@implementation VoteLinksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setButtonUI:self.checkRegistrationBtn];
    [self setButtonUI:self.registerBtn];
    [self setButtonUI:self.absenteeBtn];
}

- (void)setButtonUI:(UIButton *)button{
    button.layer.cornerRadius = 20;
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
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
