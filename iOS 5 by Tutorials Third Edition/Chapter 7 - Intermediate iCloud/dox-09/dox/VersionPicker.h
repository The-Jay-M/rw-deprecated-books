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

@property (strong, nonatomic) IBOutlet UITextView *oldContentTextView;
@property (strong, nonatomic) IBOutlet UITextView *newerContentTextView;
@property (strong, nonatomic) NSString *oldNoteContentVersion;
@property (strong, nonatomic) NSString *newerNoteContentVersion;
@property (strong, nonatomic) Note *currentNote;

- (IBAction)pickNewerVersion:(id)sender;
- (IBAction)pickOldVersion:(id)sender;

@end
