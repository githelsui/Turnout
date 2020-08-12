//
//  ElectionDetailController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/31/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ElectionDetailController.h"
#import "GoogleCivicAPI.h"
#import "Zipcode.h"
#import <Parse/PFImageView.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ElectionDetailController () <EKEventEditViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIImageView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (weak, nonatomic) IBOutlet UIButton *calendarBtn;
@property (nonatomic, strong) NSData *bookmarkInfo;
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic) BOOL didBookmark;
@end

@implementation ElectionDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    [self setElectionData];
    [self checkBookmark];
    [self loadBookmarks];
//    [self setNavigationBar];
}

- (void)setViews{
    self.mainView.clipsToBounds = true;
    self.mainView.layer.cornerRadius = 15;
    self.nameView.clipsToBounds = true;
    self.nameView.layer.cornerRadius = 15;
    self.dateView.clipsToBounds = true;
    self.dateView.layer.cornerRadius = 15;
}

- (void)setElectionData{
    self.dateLabel.text = [NSString stringWithFormat:@"Election Date: %@", self.election[@"electionDay"]];
    self.nameLabel.text = self.election[@"name"];
}

- (NSDate *)createNSDate{
    NSString *electionDate = self.election[@"electionDay"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *date = [dateFormat dateFromString:electionDate];
    return date;
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = self.election[@"name"];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
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
        NSDictionary *compare = [self.election copy];
        if([data isEqual:compare]){
            self.bookmarkInfo = bookmark;
            self.didBookmark = YES;
        }
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
    [bookmarkInfo setValue:self.election forKey:@"data"];
    NSData *data =  [NSKeyedArchiver archivedDataWithRootObject:[bookmarkInfo copy]];
    return data;
}

- (IBAction)calendarTap:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError* error){
            if(!granted){
                dispatch_async(dispatch_get_main_queue(), ^{});
            }else{
                
                EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
                addController.event = [self createEvent:eventStore];
                addController.eventStore = eventStore;
                addController.editViewDelegate = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:addController animated:YES completion:nil];
                });
            }
        }];
    }
}

- (IBAction)bookmarkTap:(id)sender {
    if(self.didBookmark == NO){
        self.didBookmark = YES;
        UIImage *bookmark = [UIImage imageNamed:@"didBookmark.png"];
        [self.bookmarkBtn setImage:bookmark forState:UIControlStateNormal];
        NSData *bookmarkInfo = [self getBookmarkInfo:@"nationalElection"];
        [self.bookmarks addObject:bookmarkInfo];
        [[NSUserDefaults standardUserDefaults] setObject:self.bookmarks forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self removeBookmark];
    }
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action{
    if (action ==EKEventEditViewActionCanceled) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (action==EKEventEditViewActionSaved) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(EKEvent*)createEvent:(EKEventStore*)eventStore{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = self.election[@"name"];
    
    event.startDate = [self createNSDate];
    event.endDate = [self createNSDate];
    
    event.location=@"National Election";
    event.allDay = YES;
    event.notes = self.election[@"name"];
    
    NSString* calendarName = @"Calendar";
    EKCalendar* calendar;
    EKSource* localSource;
    for (EKSource *source in eventStore.sources){
        if (source.sourceType == EKSourceTypeCalDAV &&
            [source.title isEqualToString:@"iCloud"]){
            localSource = source;
            break;
        }
    }
    if (localSource == nil){
        for (EKSource *source in eventStore.sources){
            if (source.sourceType == EKSourceTypeLocal){
                localSource = source;
                break;
            }
        }
    }
    calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    calendar.source = localSource;
    calendar.title = calendarName;
    NSError* error;
    [eventStore saveCalendar:calendar commit:YES error:&error];
    return event;
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
