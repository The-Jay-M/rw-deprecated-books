//
//  VersionPicker.m
//  dox
//
//  Created by Cesare Rocchi on 12/8/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "VersionPicker.h"

@interface VersionPicker ()

@end

@implementation VersionPicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Pick a version";

}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.oldContentTextView.text = self.oldNoteContentVersion;
    self.newerContentTextView.text =
    self.newerNoteContentVersion;
    
}

- (IBAction)pickNewerVersion:(id)sender {
    
    self.currentNote.noteContent =
    self.newerContentTextView.text;
    
    [self.currentNote  saveToURL:[self.currentNote fileURL]
                forSaveOperation:UIDocumentSaveForOverwriting
               completionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"versionPicked"
                                                                            object:nil];
                        [self.navigationController
                         popViewControllerAnimated:YES];
                        
                        
                    }
                    
                }];
    
}

- (IBAction)pickOldVersion:(id)sender {
    
    self.currentNote.noteContent = self.oldContentTextView.text;
    
    [self.currentNote saveToURL:[self.currentNote fileURL]
               forSaveOperation:UIDocumentSaveForOverwriting
              completionHandler:^(BOOL success) {
                  
                  if (success) {
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"versionPicked"
                                                                          object:nil];
                      
                      [self.navigationController
                       popViewControllerAnimated:YES];
                      
                  }
                  
              }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
