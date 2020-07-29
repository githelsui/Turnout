//
//  VoteWebView.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/29/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "VoteWebView.h"
#import <WebKit/WebKit.h>

@interface VoteWebView ()
@property (weak, nonatomic) IBOutlet WKWebView *webKit;

@end

@implementation VoteWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Convert the url String to a NSURL object.
    NSURL *url = [NSURL URLWithString:self.linkURL];

    // Place the URL in a URL Request.
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];
    // Load Request into WebView.
    [self.webKit loadRequest:request];
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
