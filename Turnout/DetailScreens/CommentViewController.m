//
//  CommentViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 8/6/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "CommentViewController.h"

@interface CommentViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *postUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (nonatomic) CGRect originalCommentField;
@end

@implementation CommentViewController
CGRect inputFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentField.delegate = self;
    [self.commentField resignFirstResponder];
    [self setNavigationBar];
    [self presentUI];
    [self setPostContent];
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
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self returnOriginalHeight];
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
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
