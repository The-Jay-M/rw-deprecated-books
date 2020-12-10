//
//  MatchCell.h
//  spinningyarn
//
//  Created by Jake Gundersen on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchCell : UITableViewCell 


@property (strong, nonatomic) IBOutlet UIButton *quitButton;
@property (strong, nonatomic) IBOutlet UITextView *storyText;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)loadGame:(id)sender;
- (IBAction)quitGame:(id)sender;


@end
