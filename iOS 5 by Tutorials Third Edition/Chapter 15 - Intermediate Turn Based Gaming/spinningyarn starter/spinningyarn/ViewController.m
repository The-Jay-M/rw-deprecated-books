//
//  ViewController.m
//  spinningyarn
//
//  Created by Jake Gundersen on 12/4/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import "ViewController.h"
#import "GCTurnBasedMatchHelper.h"

@interface ViewController () <UITextFieldDelegate, GCTurnBasedMatchHelperDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textInputField;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextView *mainTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUserFromViewController:self];
  [GCTurnBasedMatchHelper sharedInstance].delegate = self;
  
  self.textInputField.enabled = NO;
  self.statusLabel.text = @"Welcome. Press Game Center to get started.";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentGCTurnViewController:(id)sender
{
  [[GCTurnBasedMatchHelper sharedInstance]
   findMatchWithMinPlayers:2 maxPlayers:12
   viewController:self];
}

- (IBAction)sendTurn:(id)sender
{
  GKTurnBasedMatch *currentMatch =
  [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
  
  NSString *newStoryString;
  if ([self.textInputField.text length] > 250) {
    newStoryString =
    [self.textInputField.text substringToIndex:249];
  } else {
    newStoryString = self.textInputField.text;
  }
  
  NSString *sendString = [NSString stringWithFormat:@"%@ %@",
                          self.mainTextField.text, newStoryString];
  
  NSData *data =
  [sendString dataUsingEncoding:NSUTF8StringEncoding ];
  
  self.mainTextField.text = sendString;
  
  NSUInteger currentIndex = [currentMatch.participants
                             indexOfObject:currentMatch.currentParticipant];
  
  NSMutableArray *nextParticipants = [NSMutableArray array];
  for (NSInteger i = 0; i < [currentMatch.participants count]; i++){
    NSInteger indx = (i + currentIndex + 1) %
    [currentMatch.participants count];
    GKTurnBasedParticipant *participant =
    [currentMatch.participants objectAtIndex:indx];
    //1
    if (participant.matchOutcome ==
        GKTurnBasedMatchOutcomeNone) {
      [nextParticipants addObject:participant];
    }
    
  }
  
  if ([data length] > 3800) {
    for (GKTurnBasedParticipant *part in
         currentMatch.participants) {
      part.matchOutcome = GKTurnBasedMatchOutcomeTied;
    }
    [currentMatch endMatchInTurnWithMatchData:data
                            completionHandler:^(NSError *error) {
                              if (error) {
                                NSLog(@"%@", error);
                              }
                            }];
    self.statusLabel.text = @"Game has ended";
  } else {
    [currentMatch endTurnWithNextParticipants:nextParticipants
                                  turnTimeout:36000 matchData:data completionHandler:
     ^(NSError *error) {
       if (error) {
         NSLog(@"%@", error);
         self.statusLabel.text = @"Oops, there was a problem. Try that again.";
       } else {
         self.statusLabel.text = @"Your turn is over.";
         self.textInputField.enabled = NO;
       }
       
     }];
  }
  
  NSLog(@"Send Turn, %@, %@", data, nextParticipants);
  self.textInputField.text = @"";
  self.characterCountLabel.text = @"250";
  self.characterCountLabel.textColor = [UIColor blackColor];
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

- (void)checkForEnding:(NSData *)matchData {
    if ([matchData length]) {
        self.statusLabel.text = [NSString stringWithFormat:
                                 @"%@, only about %lu letter left",
                                 self.statusLabel.text, 4000 - [matchData length]];
    }
}

#pragma mark CGTurnBasedMatchHelperDelegate methods

-(void)enterNewGame:(GKTurnBasedMatch *)match {
  NSLog(@"Entering new game...");
  NSInteger playerNum = [match.participants
                   indexOfObject:match.currentParticipant] + 1;
  self.statusLabel.text = [NSString stringWithFormat:
                           @"Player %ld's Turn (that's you)", playerNum];
  self.textInputField.enabled = YES;
  self.mainTextField.text = @"Once upon a time";
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
  NSLog(@"Taking turn for existing game...");
  NSInteger playerNum = [match.participants
                   indexOfObject:match.currentParticipant] + 1;
  NSString *statusString = [NSString stringWithFormat:
                            @"Player %ld's Turn (that's you)", playerNum];
  self.statusLabel.text = statusString;
  self.textInputField.enabled = YES;
  __weak typeof(self) weakself = self;
  [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
    if ([matchData bytes]) {
      NSString *storySoFar = [NSString stringWithUTF8String:[matchData bytes]];
      dispatch_async(dispatch_get_main_queue(), ^{
        weakself.mainTextField.text = storySoFar;
      });
      [self checkForEnding:match.matchData];
    }
  }];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
  
  NSLog(@"Viewing match where it's not our turn...");
  NSString *statusString;
  
  if (match.status == GKTurnBasedMatchStatusEnded) {
    statusString = @"Match Ended";
  } else {
    NSUInteger playerNum = [match.participants
                     indexOfObject:match.currentParticipant] + 1;
    statusString = [NSString stringWithFormat:
                    @"Player %ld's Turn", playerNum];
  }
  
  self.statusLabel.text = statusString;
  self.textInputField.enabled = NO;
  __weak typeof(self) weakself = self;
  [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
    if (matchData) {
      NSString *storySoFar = [NSString
                              stringWithUTF8String:[matchData bytes]];
      dispatch_async(dispatch_get_main_queue(), ^{
        weakself.mainTextField.text = storySoFar;
      });
      [self checkForEnding:match.matchData];
    }
  }];
}

- (void)sendNotice:(NSString *)notice forMatch:
(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:
                       @"Another game needs your attention!" message:notice
                                                delegate:self cancelButtonTitle:@"Sweet!"
                                       otherButtonTitles:nil];
    [av show];
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
  [self layoutMatch:match];
}


@end
