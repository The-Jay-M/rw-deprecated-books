//
//  DetailViewController.h
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import <MessageUI/MessageUI.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Note *detailItem;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

- (NSURL *) generateExportURL;

@end
