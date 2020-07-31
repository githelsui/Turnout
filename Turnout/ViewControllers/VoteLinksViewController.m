//
//  VoteLinksViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/28/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VoteLinksViewController.h"
#import "VoteWebView.h"

@interface VoteLinksViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkRegistrationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backgrndView;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *absenteeBtn;
@property (nonatomic, strong) NSString *linkURL;

@end

@implementation VoteLinksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self setButtonUI:self.checkRegistrationBtn];
    [self setButtonUI:self.registerBtn];
    [self setButtonUI:self.absenteeBtn];
}

- (void)setUI{
    self.backgrndView.alpha = 0.67;
    self.backgrndView.layer.cornerRadius = 15;
}

- (void)setButtonUI:(UIButton *)button{
    button.layer.cornerRadius = 20;
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
}

- (IBAction)checkRegistrationTapped:(id)sender {
    self.linkURL = @"https://www.vote.org/am-i-registered-to-vote/";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"checkRegisterSegue"]){
         VoteWebView *webView = [segue destinationViewController];
         webView.linkURL = @"https://www.vote.org/am-i-registered-to-vote/";
    }
    else if ([segue.identifier isEqualToString:@"registerSegue"]){
         VoteWebView *webView = [segue destinationViewController];
         webView.linkURL = @"https://www.vote.org/register-to-vote/";
    }
    else if ([segue.identifier isEqualToString:@"absenteeSegue"]){
         VoteWebView *webView = [segue destinationViewController];
         webView.linkURL = @"https://www.vote.org/absentee-ballot/";
    }
}

@end
