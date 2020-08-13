//
//  PropViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/2/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "PropViewController.h"
#import "ProPublicaAPI.h"
#import "VoteWebView.h"

@interface PropViewController ()
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UILabel *longTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *textsBtn;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (nonatomic, strong) NSString *propId;
@property (nonatomic, strong) NSDictionary *propInfo;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabel;
@property (nonatomic, strong) NSString *textsURL;
@property (weak, nonatomic) IBOutlet UIView *subjectView;
@property (weak, nonatomic) IBOutlet UILabel *chamberLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *committeeLabel;
@property (nonatomic, strong) NSString *actionsURL;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic) BOOL didBookmark;
@end

@implementation PropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self checkBookmark];
    [self loadBookmarks];
    [self prepAnimation];
    [self setBasicUI];
    [self setPropInfo];
    [self fetchPropDetails];
}

- (void)setBasicUI{
    self.mainView.clipsToBounds = true;
    self.mainView.layer.cornerRadius = 15;
    self.nameView.clipsToBounds = true;
    self.nameView.layer.cornerRadius = 15;
    self.generalView.clipsToBounds = true;
    self.generalView.layer.cornerRadius = 15;
    self.dateView.clipsToBounds = true;
    self.dateView.layer.cornerRadius = 15;
    self.subjectView.layer.cornerRadius = 15;
    self.subjectView.clipsToBounds = true;
    self.textsBtn.layer.cornerRadius = 15;
    self.actionBtn.layer.cornerRadius = 15;
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Proposition Details";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)prepAnimation{
    self.nameView.alpha = 0;
    self.generalView.alpha = 0;
    self.dateView.alpha = 0;
    self.subjectView.alpha = 0;
    self.textsBtn.alpha = 0;
    self.actionBtn.alpha = 0;
    self.bookmarkBtn.alpha = 0;
}

- (void)startAnimate{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.nameView.alpha = 1;
    } completion:^(BOOL finished) {
        [self animateGeneralView];
    }];
}

- (void)animateGeneralView{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.generalView.alpha = 1;
        self.subjectView.alpha = 1;
        self.dateView.alpha = 1;
    } completion:^(BOOL finished) {
        [self animateButtons];
    }];
}

- (void)animateButtons{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.textsBtn.alpha = 1;
        self.actionBtn.alpha = 1;
        self.bookmarkBtn.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)setPropInfo{
    self.propId = self.prop[@"bill_slug"];
}

- (void)setPropFetchedInfo{
    NSString *date = [NSString stringWithFormat: @"Legislative Date: %@", self.prop[@"legislative_day"]];
    self.dateLabel.text = date;
    self.nameLabel.text = self.propInfo[@"short_title"];
    self.longTitleLabel.text = self.propInfo[@"title"];
    self.textsURL = self.propInfo[@"congressdotgov_url"];
    self.actionsURL = self.propInfo[@"govtrack_url"];
    self.chamberLabel.text = [NSString stringWithFormat:@"Chamber: %@", [self getChamber]];
    self.sponsorLabel.text = [NSString stringWithFormat:@"Sponsor: %@", self.propInfo[@"sponsor"]];
    self.subjectLabel.text = [NSString stringWithFormat:@"Subject: %@", self.propInfo[@"primary_subject"]];
    self.committeeLabel.text = [NSString stringWithFormat:@"Committee: %@", self.propInfo[@"committees"]];
}

- (NSString *)getChamber{
    NSString *chamber = self.prop[@"chamber"];
    if([chamber isEqualToString:@"house"]) return @"House of Representatives";
    else return chamber;
}

- (void)fetchPropDetails{
    [[ProPublicaAPI shared]fetchBillInfo:self.propId completion:^(NSArray *details, NSError *error){
        if(details){
            self.propInfo = details[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPropFetchedInfo];
                [self startAnimate];
            });
        }
    }];
}

- (void)removeBookmark{
    self.didBookmark = NO;
    UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
    [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    [self.bookmarks removeObject:self.bookmarkInfo];
    [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)getBookmarkInfo:(NSString *)type{
    NSMutableDictionary *bookmarkInfo = [NSMutableDictionary new];
    [bookmarkInfo setValue:type forKey:@"type"];
    [bookmarkInfo setValue:self.prop forKey:@"data"];
    NSData *data =  [NSKeyedArchiver archivedDataWithRootObject:[bookmarkInfo copy]];
    return data;
}

- (void)loadBookmarks{
    if(self.didBookmark == YES){
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    } else {
        UIImage *bookmark = [UIImage imageNamed:@"notBookmarked.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
    }
}

- (void)checkBookmark{
    self.didBookmark = NO;
    self.bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    for(NSData *bookmark in self.bookmarks){
        NSDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:bookmark];
        NSDictionary *data = bookmarkDict[@"data"];
        NSDictionary *compare = [self.prop copy];
        if([data isEqual:compare]){
            self.bookmarkInfo = bookmark;
            self.didBookmark = YES;
        }
    }
}

- (IBAction)tapBookmark:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSDictionary *bookmarkInfo = [self getBookmarkInfo:@"propInfo"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.delegate refreshFeed];
    } else {
        [self removeBookmark];
        [self.delegate refreshFeed];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PropTextsSegue"]){
        VoteWebView *webView = [segue destinationViewController];
        webView.linkURL = self.textsURL;
    } else if([segue.identifier isEqualToString:@"PropActionsSegue"]){
        VoteWebView *webView = [segue destinationViewController];
        webView.linkURL = self.actionsURL;
    }
}

@end
