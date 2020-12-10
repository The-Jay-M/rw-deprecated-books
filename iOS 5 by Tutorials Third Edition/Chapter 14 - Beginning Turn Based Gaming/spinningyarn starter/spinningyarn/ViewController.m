//
//  ViewController.m
//  spinningyarn
//
//  Created by Jake Gundersen on 12/4/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textInputField;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextView *mainTextField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 210; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    int textFieldMovement = movement * 0.75;
    self.textInputView.frame = CGRectOffset(self.textInputView.frame, 0, movement);
    self.mainTextField.frame = CGRectMake(self.mainTextField.frame.origin.x, self.mainTextField.frame.origin.y, self.mainTextField.frame.size.width, self.mainTextField.frame.size.height + textFieldMovement);
    [UIView commitAnimations];
}

- (IBAction)updateCount:(id)sender {
    UITextField *tf = (UITextField *)sender;
    NSInteger len = [tf.text length];
    NSInteger remain = 250 - len;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%ld", (long)remain];
    if (remain < 0) {
        self.characterCountLabel.textColor = [UIColor redColor];
    } else {
        self.characterCountLabel.textColor = [UIColor blackColor];
    }
}


@end
