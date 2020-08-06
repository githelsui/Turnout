//
//  CandidateDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CandidateDetailController.h"
#import "OpenFECAPI.h"

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
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic) BOOL didBookmark;
@end

@implementation CandidateDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.candidateId = self.candidate[@"candidate_id"];
    [self setUI];
    [self setNavigationBar];
    [self fetchCandidateInfo];
}

- (void)setUI{
    [self checkBookmark];
    [self loadBookmarks];
    self.backColor.alpha = 0.70;
    self.backColor.layer.cornerRadius = 15;
    self.nameView.layer.cornerRadius = 15;
    self.infoView.layer.cornerRadius = 15;
    self.nameView.alpha = 0;
    self.infoView.alpha = 0;
    self.bookmarkBtn.alpha = 0;
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Specific Candidate";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)setInfoDetails{
    NSString *name = self.details[@"name"];
    NSString *office = self.candidate[@"office"];
    NSString *party = self.candidate[@"party"];
    NSString *candidateType = self.candidate[@"candidateType"];
    NSString *state = self.details[@"address_state"];
    NSString *city = self.details[@"address_city"];
    NSString *loc = [NSString stringWithFormat:@"%@, %@", city, state];
    NSString *district = [NSString stringWithFormat:@"Election District: %@", self.details[@"district"]];
    self.nameLabel.text = name;
    self.officeLabel.text = office;
    self.partyLabel.text = party;
    self.candidateLabel.text = candidateType;
    self.locLabel.text = loc;
    self.districtLabel.text = district;
}

- (void)fetchCandidateInfo{
    [[OpenFECAPI shared]fetchCandidateDetails:self.candidateId completion:^(NSArray *details, NSError *error){
        if(details){
            self.details = details[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setInfoDetails];
                [self animateInfo];
            });
        }
    }];
}

- (void)animateInfo{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.infoView.alpha = 1;
        self.nameView.alpha = 1;
        self.bookmarkBtn.alpha = 1;
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
