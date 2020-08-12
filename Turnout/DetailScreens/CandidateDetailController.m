//
//  CandidateDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CandidateDetailController.h"
#import <CCActivityHUD.h>
#import "OpenFECAPI.h"
#import "VoteWebView.h"
#import "ProPublicaAPI.h"

@interface CandidateDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
@property (weak, nonatomic) IBOutlet UILabel *partyLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLabel;
@property (weak, nonatomic) IBOutlet UILabel *districtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backColor;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *locLabel;
@property (nonatomic, strong) NSString *candidateId;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSDictionary *actualCand;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (weak, nonatomic) IBOutlet UIButton *websiteBtn;
@property (nonatomic) BOOL didBookmark;
@end

@implementation CandidateDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actualCand = self.candidate[@"candidate"];
    self.candidateId = self.actualCand[@"id"];
    [self setUI];
    [self fetchCandidateInfo];
}

- (void)setUI{
    [self checkBookmark];
    [self loadBookmarks];
    self.backColor.alpha = 0.70;
    self.fbBtn.alpha = 0;
    self.websiteBtn.alpha = 0;
    self.backColor.layer.cornerRadius = 15;
    self.nameView.layer.cornerRadius = 15;
    self.infoView.layer.cornerRadius = 15;
    self.nameView.alpha = 0;
    self.infoView.alpha = 0;
    self.bookmarkBtn.alpha = 0;
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
    self.activityHUD.hidden = NO;
}

- (void)setInfoDetails{
    NSString *name = self.details[@"display_name"];
    NSString *party = [self getParty:self.details[@"party"]];
    NSString *candidateType = [self getType:self.details[@"status"]];
    NSString *state = self.state;
    NSString *city = self.details[@"mailing_city"];
    NSString *loc = [NSString stringWithFormat:@"%@, %@", city, state];
    NSString *district = [NSString stringWithFormat:@"Election District: %@", self.details[@"district"]];
    self.nameLabel.text = name;
    self.officeLabel.text = @"Congressional Candidate";
    self.partyLabel.text = party;
    self.candidateLabel.text = candidateType;
    self.locLabel.text = loc;
    self.districtLabel.text = district;
}

- (NSString *)getType:(NSString *)type{
    if([type isEqual:[NSNull null]]){
        return @"Status: N/A";
    } else if([type isEqualToString:@"C"]) return @"Status: Challenger";
    else return @"Status: Incumbent";
}

- (NSString *)getParty:(NSString *)type{
    if([type isEqualToString:@"DEM"]) return @"Democratic Party";
    else return @"Republican Party";
}

- (void)fetchCandidateInfo{
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [[ProPublicaAPI shared]fetchSpecificCand:self.candidateId completion:^(NSDictionary *details, NSError *error){
        if(details){
            self.details = details;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setInfoDetails];
                [self animateInfo];
                [self.activityHUD dismiss];
            });
        }
    }];
}

- (IBAction)tapFacebook:(id)sender {
    NSString *url = self.details[@"facebook_url"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VoteWebView *web = [storyboard instantiateViewControllerWithIdentifier:@"VoteWebView"];
    web.linkURL = url;
    [self presentViewController:web animated:YES completion:nil];
}

- (IBAction)tapWebsite:(id)sender {
    NSString *url = self.details[@"url"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VoteWebView *web = [storyboard instantiateViewControllerWithIdentifier:@"VoteWebView"];
    web.linkURL = url;
    [self presentViewController:web animated:YES completion:nil];
    
}

- (void)animateInfo{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.infoView.alpha = 1;
        self.nameView.alpha = 1;
        self.bookmarkBtn.alpha = 1;
        self.fbBtn.alpha = 1;
        self.websiteBtn.alpha = 1;
    } completion:^(BOOL finished) {}];
}

- (IBAction)tapBookmark:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSDictionary *bookmarkInfo = [self getBookmarkInfo:@"candidateInfo"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.delegate refreshFeed];
    } else {
        [self removeBookmark];
        [self.delegate refreshFeed];
    }
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
    [bookmarkInfo setValue:self.state forKey:@"state"];
    [bookmarkInfo setValue:type forKey:@"type"];
    [bookmarkInfo setValue:self.candidate forKey:@"data"];
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
        NSDictionary *compare = [self.candidate copy];
        if([data isEqual:compare]){
            self.bookmarkInfo = bookmark;
            self.didBookmark = YES;
        }
    }
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
