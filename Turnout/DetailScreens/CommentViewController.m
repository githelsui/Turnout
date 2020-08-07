//
//  CommentViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CommentViewController.h"
#import "Comment.h"
#import "CommentCell.h"

@interface CommentViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *postUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (nonatomic) CGRect originalCommentField;
@property (nonatomic) CGRect typingCommentField;
@property (nonatomic, strong) NSArray *comments;
@end

@implementation CommentViewController
CGRect inputFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.commentField.delegate = self;
    [self.commentField resignFirstResponder];
    [self setNavigationBar];
    [self presentUI];
    [self setPostContent];
    [self queryComments];
}

- (void)queryComments{
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query orderByAscending:@"createdAt"];
    [query whereKey:@"post" equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.comments = comments;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)presentUI{
     UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.commentField.leftView = paddingView;
    self.commentField.leftViewMode = UITextFieldViewModeAlways;
    self.commentField.layer.cornerRadius = 17;
    self.commentBtn.layer.cornerRadius = 17;
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Comments";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont systemFontOfSize:22 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)setPostContent{
    PFUser *user = self.post.author;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error){
        if(user){
            self.postUserLabel.text = user[@"username"];
        }
    }];
    NSString *timeAgoStr = [self.post getTimeAgo:self.post];
    self.timeAgoLabel.text = timeAgoStr;
    self.postLabel.text = self.post.status;
}

- (void)changeCommentFieldHeight{
    inputFrame = self.commentView.frame;
    self.originalCommentField = self.commentView.frame;
    [UIView animateWithDuration:0.2 animations:^{
        inputFrame.origin.y -= 310;
        self.commentView.frame = inputFrame;
        self.typingCommentField = inputFrame;
    }];
}

- (void)saveCommentCount{
    self.post.commentCount = @([self.post.commentCount intValue] + [@1 intValue]);
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}

- (void)returnOriginalHeight{
    [UIView animateWithDuration:0.2 animations:^{
        self.commentView.frame = self.originalCommentField;
    }];
}

- (IBAction)tapOutside:(id)sender {
    [self.view endEditing:YES];
    [self returnOriginalHeight];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)textfieldTapped:(id)sender {
    [self changeCommentFieldHeight];
}

- (IBAction)enterTapped:(id)sender {
    [[self view] endEditing:YES];
    [self returnOriginalHeight];
    if(self.commentField.text.length > 0) [self saveComment];
}

- (void)saveComment{
    [self saveCommentCount];
    NSString *comment = self.commentField.text;
    self.commentField.text = @"";
    [[Comment class]saveComment:comment post:self.post withCompletion:^(BOOL succeeded, NSError * _Nullable error){
        if(succeeded){
            [self queryComments];
        }
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (IBAction)typingContinues:(id)sender {
    self.commentView.frame = self.typingCommentField;
    NSLog(@"why");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self returnOriginalHeight];
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    if (cell == nil) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentCell"];
    }
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    Comment *comment = self.comments[indexPath.row];
    cell.comment = comment;
    [cell setCellContent];
    return cell;
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
