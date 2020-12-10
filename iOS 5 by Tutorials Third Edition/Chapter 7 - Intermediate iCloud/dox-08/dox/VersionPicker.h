//
//  VersionPicker.h
//  dox
//
//  Created by Cesare Rocchi on 12/8/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface VersionPicker : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *thisDeviceContentTextView;
@property (strong, nonatomic) IBOutlet UITextView *otherDeviceContentTextView;
@property (strong, nonatomic) NSString *thisDeviceContentVersion;
@property (strong, nonatomic) NSString *otherDeviceContentVersion;
@property (strong, nonatomic) Note *currentNote;

- (IBAction)pickOtherDeviceVersion:(id)sender;
- (IBAction)pickThisDeviceVersion:(id)sender;

- (void) cleanConflicts;

@end
