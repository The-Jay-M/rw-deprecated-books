//
//  DetailViewController.m
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "DetailViewController.h"
#import "VersionPicker.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
        
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.noteTextView.text = self.detailItem.noteContent;
    
    UIBarButtonItem *exportButtonItem =
    [[UIBarButtonItem alloc]
     initWithTitle:@"Export"
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(sendNoteURL)];
    
    self.navigationItem.rightBarButtonItem = exportButtonItem;
    
}

- (void)configureView
{
    if (self.detailItem) {
        self.noteTextView.text = self.detailItem.noteContent;
        
        if (self.detailItem.documentState ==
            UIDocumentStateSavingError) {
            
            UIBarButtonItem *reinstateNoteButton =
            [[UIBarButtonItem alloc]
             initWithTitle:@"Reinstate"
             style:UIBarButtonItemStylePlain
             target:self
             action:@selector(reinstateNote)];
            
            self.navigationItem.rightBarButtonItem =
            reinstateNoteButton;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    self.noteTextView.backgroundColor =
    [UIColor lightGrayColor];
    
    if (self.detailItem.documentState ==
        UIDocumentStateSavingError) {
        
        UIBarButtonItem *reinstateNoteButton =
        [[UIBarButtonItem alloc]
         initWithTitle:@"Reinstate"
         style:UIBarButtonItemStylePlain
         target:self
         action:@selector(reinstateNote)];
        
        self.navigationItem.rightBarButtonItem =
        reinstateNoteButton;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(noteHasChanged:)
     name:UIDocumentStateChangedNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(versionPicked:)
                                                 name:@"versionPicked"
                                               object:nil];
    
}

- (void) versionPicked:(NSNotification *) notification {

        self.noteTextView.text = self.detailItem.noteContent;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    
}

- (void)noteHasChanged:(id)sender {
    
    if (!self.detailItem)
        return;
    
    if (self.detailItem.documentState ==
        UIDocumentStateSavingError) {
        self.title = @"Limbo note";
        UIBarButtonItem *reinstateNoteButton =
        [[UIBarButtonItem alloc]
         initWithTitle:@"Reinstate"
         style:UIBarButtonItemStylePlain
         target:self
         action:@selector(reinstateNote)];
        
        self.navigationItem.rightBarButtonItem =
        reinstateNoteButton;
        
    }
    
    
    if (self.detailItem.documentState ==
        UIDocumentStateEditingDisabled) {
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        NSLog(@"document state is  UIDocumentStateEditingDisabled");
        
    }
    
    if (self.detailItem.documentState == UIDocumentStateNormal)
    {
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        NSLog(@"old content is %@", self.noteTextView.text);
        NSLog(@"new content is %@",
              self.detailItem.noteContent);
        
        if (![self.noteTextView.text
              isEqualToString:self.detailItem.noteContent]) {
            
            UIBarButtonItem * resolveButton =
            [[UIBarButtonItem alloc]
             initWithTitle:@"Resolve"
             style:UIBarButtonItemStylePlain
             target:self
             action:@selector(resolveNote)];
            
            self.navigationItem.rightBarButtonItem =
            resolveButton;
            
        }
        
    }
    
}

- (void)mailComposeController:
(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    if (result == MFMailComposeResultSent) {
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
    }
    
}


- (void) resolveNote {
    
    VersionPicker *picker = [[VersionPicker alloc]
                             initWithNibName:@"VersionPicker"
                             bundle:nil];

    picker.newerNoteContentVersion =
    self.detailItem.noteContent;
    picker.oldNoteContentVersion = self.noteTextView.text;
    picker.currentNote = self.detailItem;
    
    [self.navigationController pushViewController:picker
                                         animated:YES];
}

- (void) reinstateNote {
    
    // Generate new filename for note based on date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"Note_%@",
                          [formatter stringFromDate:
                           [NSDate date]]];
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage =
    [[ubiq URLByAppendingPathComponent:@"Documents"]
     URLByAppendingPathComponent:fileName];
    
    // Create new note and save it
    Note *n = [[Note alloc]
                 initWithFileURL:ubiquitousPackage];
    n.noteContent = self.noteTextView.text;
    
    [n saveToURL:[n fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:
             @"com.studiomagnolia.noteReinstated"
             object:self];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] ==
                UIUserInterfaceIdiomPad) {
                self.detailItem = nil;
                self.noteTextView.text = @"";
            } else {
                [self.navigationController
                 popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"error in saving reinstated note");
        }
    }];
}


- (void) sendNoteURL {
    
    NSURL *url = [self generateExportURL];
    
    MFMailComposeViewController *mailComposer;
    mailComposer  = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer
     setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailComposer setSubject:@"Download my note"];
    [mailComposer setMessageBody:[NSString stringWithFormat:
                                  @"The note can be downloaded at the following url:\n %@ \n \n It will expire in one hour.", url]
                          isHTML:NO];
    
    [self presentViewController:mailComposer
                       animated:YES
                     completion:nil];
    
}

- (NSURL *) generateExportURL {
    
    NSTimeInterval oneHourInterval = 3600.0;
    NSDate *expirationInOneHourSinceNow =
    [NSDate dateWithTimeInterval:oneHourInterval
                       sinceDate:[NSDate date]];
    NSError *err;
    
    NSURL *url = [[NSFileManager defaultManager]
                  URLForPublishingUbiquitousItemAtURL:
                  [self.detailItem fileURL]
                  expirationDate:&expirationInOneHourSinceNow
                  error:&err];
    if (err)
        return nil;
    else
        return url;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
