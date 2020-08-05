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
@property (weak, nonatomic) IBOutlet UIImageView *backgrndView;
@property (nonatomic, strong) NSString *linkURL;
@property (weak, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIView *absenteeView;
@property (weak, nonatomic) IBOutlet UIView *voteByMail;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@end

@implementation VoteLinksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI{
    [self createShadows];
    self.backgrndView.alpha = 0.90;
    self.verifyView.layer.cornerRadius = 15;
    self.registerView.layer.cornerRadius = 15;
    self.absenteeView.layer.cornerRadius = 15;
    self.voteByMail.layer.cornerRadius = 15;
}

- (void)createShadows{
    self.bubbleView.clipsToBounds = NO;
    self.bubbleView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bubbleView.layer.shadowRadius = 5;
    self.bubbleView.layer.shadowOpacity = 1;
    self.backgrndView.clipsToBounds = YES;
    self.backgrndView.layer.cornerRadius = 15;
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
    } else if([segue.identifier isEqualToString:@"mailSegue"]){
        VoteWebView *webView = [segue destinationViewController];
        webView.linkURL = @"https://votesaveamerica.com/everylastvote/#text-block-wysiwyg";
    }
}

@end
