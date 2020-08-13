//
//  LiveFeedController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/13/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "LiveFeedController.h"

@interface LiveFeedController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentLoc;
@property (weak, nonatomic) IBOutlet UILabel *currentZipcode;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *mutablePosts;
@property (nonatomic, strong) RankAlgorithm *rankAlgo;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *loadMoreBtn;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property int skipIndex;
@property int pageNum;
@end

@implementation LiveFeedController
NSTimeInterval lastClick;
NSIndexPath *lastIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepNotifications];
//    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]]; //resets userdefaults
    [self loadBookmarks];
    self.pageNum = 1;
    [self initTableView];
    [self customizeActivityIndic];
    self.rankAlgo = [[RankAlgorithm alloc]init];
    [self loadFeed];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFeed) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)loadBookmarks{
    NSMutableArray *bookmarks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Bookmarks"] mutableCopy];
    if(bookmarks == nil) {
        bookmarks = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:bookmarks forKey:@"Bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
}

- (void)initTableView{
    [self setNavigationBar];
    [self setUpHeader];
    self.mutablePosts =  [NSMutableArray array];
    self.tableView.allowsSelection = false;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setGestureRecogs];
}

- (void)presentAlert:(NSString *)title msg:(NSString *)msg{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.cornerRadius = 20;
    alert.colorScheme = alert.flatOrange;
    alert.detachButtons = YES;
    alert.titleFont = [UIFont systemFontOfSize:25 weight:UIFontWeightThin];
    alert.subtitleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    [alert showAlertInView:self
              withTitle:title
           withSubtitle:msg
        withCustomImage:nil
    withDoneButtonTitle:@"OK"
             andButtons:nil];
}

- (void)setUpHeader{
    self.currentLoc.alpha = 0;
    self.currentZipcode.alpha = 0;
    self.currentUser = PFUser.currentUser;
    Zipcode *zip = self.currentUser[@"zipcode"];
    [zip fetchIfNeededInBackgroundWithBlock:^(PFObject *zipcode, NSError *error){
        if(zipcode){
            NSString *location = [NSString stringWithFormat:@"%@, %@", zipcode[@"city"], zipcode[@"shortState"]];
            self.currentLoc.text = location;
            self.currentZipcode.text = zipcode[@"zipcode"];
            [UIView animateWithDuration:0.5 animations:^{
                self.currentLoc.alpha = 1;
                self.currentZipcode.alpha = 1;
            }];
        }
    }];
}

- (void)setUpFooter{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    self.loadMoreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadView.alpha = 1;
    self.loadMoreBtn.alpha = 1;
    [self.loadMoreBtn setTitle:@"Load More" forState:UIControlStateNormal];
    [self.loadMoreBtn addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    self.loadMoreBtn.frame = CGRectMake(0, 0, self.view.bounds.size.width - 10, 50);
    [self.loadMoreBtn setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.loadMoreBtn.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightThin];
    loadView.center = CGPointMake(self.view.center.x, 0);
    self.loadMoreBtn.center = CGPointMake(self.view.center.x, 30);
    self.loadMoreBtn.layer.cornerRadius = 20;
    self.loadMoreBtn.layer.borderWidth = 0.5f;
    self.loadMoreBtn.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f].CGColor;
    [loadView addSubview:self.loadMoreBtn];
    self.tableView.tableFooterView = loadView;
    [UIView animateWithDuration:4 animations:^{
        loadView.alpha = 1;
        self.loadMoreBtn.alpha = 1;
    }];
}

- (void)startTimer{
    if(self.currentUser){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
            self.timer = [NSTimer timerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(reloadData)
                                               userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
            });
        });
    }
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Turnout";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    lblTitle.font = [UIFont systemFontOfSize:28 weight:UIFontWeightThin];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage
    imageNamed:@"yourImageName"] style:UIBarButtonItemStylePlain target:self
                                                                 action:@selector(goBack:)];
    myBackButton.tintColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem = myBackButton;
}

- (void)loadFeed{
    [self.mutablePosts removeAllObjects];
    self.loadMoreBtn.alpha = 0;
    self.skipIndex = 0;
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [self.rankAlgo queryPosts:0 completion:^(NSArray *posts, NSError *error){
        if(posts.count > 0){
            self.posts = posts;
            [self loadLivefeed];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self setUpFooter];
                [self startTimer];
            });
        }
        [self.activityHUD dismiss];
    }];
    [self.refreshControl endRefreshing];
}

- (void)fetchMorePosts{
    self.pageNum++;
    [self presentToLivefeed];
    [self.tableView reloadData];
    [self setUpFooter];
}

- (void)setGestureRecogs{
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.tableView addGestureRecognizer:singleTap];
}

- (void)presentToLivefeed{
    NSArray *livefeed = [NSArray array];
    NSRange range;
    int postsPerPage = 8 * self.pageNum;
    if(self.posts.count > postsPerPage){
        range.location = 0;
        range.length = postsPerPage;
        livefeed = [self.posts subarrayWithRange:range];
        self.mutablePosts = [livefeed mutableCopy];
    } else if(self.posts.count == self.mutablePosts.count){
         [self presentAlert:@"Refresh the Live Feed" msg:@"No more posts left to fetch."];
    } else if(self.posts.count <= postsPerPage){
        self.mutablePosts = [self.posts mutableCopy];
    }
}

- (void)loadLivefeed{
    int postsPerPage = 8;
    NSArray *livefeed = [NSArray array];
    NSRange range;
    if(self.posts.count > postsPerPage){
        range.location = 0;
        range.length = postsPerPage;
        livefeed = [self.posts subarrayWithRange:range];
        self.mutablePosts = [livefeed mutableCopy];
    } else if(self.posts.count <= postsPerPage){
        self.mutablePosts = [self.posts mutableCopy];
    }
}

- (IBAction)logoutTapped:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    sceneDelegate.window.rootViewController = loginViewController;
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mutablePosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    if(self.mutablePosts.count > 0){
        Post *post = self.mutablePosts[indexPath.row];
        cell.post = post;
        cell.delegate = self;
        [cell setCell];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(void)singleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"Single Tap");
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        Post *post = self.mutablePosts[indexPath.row];
        PostDetailController *detailController = [[PostDetailController alloc] init];
        detailController.post = post;
        [self performSegueWithIdentifier:@"DetailSegue" sender:cell];
    }
}

-(void)doubleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"Double Taps");
    
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint: point];
    PostCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell doubleTapped];
}

- (void)loadMore{
    [UIView animateWithDuration:1 animations:^{
        self.loadMoreBtn.backgroundColor = [UIColor colorWithRed:255.0f/255.0f
                                                          green:180.0f/255.0f
                                                           blue:171.0f/255.0f
                                                          alpha:1.0f];
        [self.loadMoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            [self.loadMoreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.loadMoreBtn.backgroundColor = [UIColor whiteColor];
        }];
    }];
    [self fetchMorePosts];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)receiveSettingUpdate:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"SettingNotification"]){
        NSLog(@"Successfully received the test notification!");
        [self.timer invalidate];
        [self setUpHeader];
        [self loadFeed];
    }
}

- (void)prepNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(receiveSettingUpdate:)
           name:@"SettingNotification"
           object:nil];
}

- (void)postToTopFeed:(Post *)post {
    [self.mutablePosts insertObject:post atIndex:0];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSegue"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.mutablePosts[indexPath.row];
        NSLog(@"post being passed %@", post);
        PostDetailController *detailController = [segue destinationViewController];
        detailController.post = post;
    } else if ([segue.identifier isEqualToString:@"ComposeSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
}

@end
