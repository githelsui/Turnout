//
//  ComposeViewController.m
//  Turnout
//
//  Created by Githel Lynn Suico on 7/14/20.
//  Copyright © 2020 Githel Lynn Suico. All rights reserved.
//

#import "ComposeViewController.h"
#import <CCActivityHUD.h>
#import "Post.h"

@interface ComposeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImage;
@property (nonatomic, strong) UIImage *imagePost;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) CCActivityHUD *activityHUD;
@property (weak, nonatomic) IBOutlet UILabel *textMessage;
@property (nonatomic, strong) NSString *timeString;
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self customizeActivityIndic];
    [self setViews];
    [self.textView setDelegate:self];
}

- (void)customizeActivityIndic{
    self.activityHUD = [CCActivityHUD new];
    self.activityHUD.cornerRadius = 30;
    self.activityHUD.indicatorColor = [UIColor systemPinkColor];
    self.activityHUD.backColor =  [UIColor whiteColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.textMessage.alpha = 0;
}

- (void)setViews{
    self.attachedImage.alpha = 0;
    [self getDateTime];
    self.dateLabel.text = self.dateString;
    self.timeLabel.text = self.timeString;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)setNavigationBar{
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"New Status";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:169.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    lblTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
}

- (void)getDateTime{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    self.timeString = [outputFormatter stringFromDate:now];
    [outputFormatter setDateFormat:@"E MMM d, y"];
    self.dateString = [outputFormatter stringFromDate:now];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(400.0, 400.0);
    UIImage *editedImage = [self resizeImage:originalImage withSize:size];
    self.imagePost = editedImage;
    [self.attachedImage setImage:self.imagePost];
    self.attachedImage.alpha = 1;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraTapped:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)photoTapped:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)postStatus:(id)sender {
    if(self.textView.text.length == 0 && self.imagePost == nil){
        [self showAlert:@"Cannot post empty status" msg:@""];
    } else {
        NSString *status = self.textView.text;
        UIImage *imageToPost = self.imagePost;
        [self postWithImage:status image:imageToPost];
    }
}

- (void)postWithImage:(NSString *)status image:(UIImage *)image{
    Post *post = [Post createNewPost:image withStatus:status date:self.dateString time:self.timeString];
    [self.activityHUD showWithType:CCActivityHUDIndicatorTypeDynamicArc];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (error) {
            [self showAlert:error.localizedDescription msg:@""];
        } else {
            [self.activityHUD dismiss];
            [self.delegate postToTopFeed:post];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
