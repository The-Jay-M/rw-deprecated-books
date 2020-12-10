//
//  DetailViewController.m
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "DetailViewController.h"

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

- (void)configureView {

    if (self.detailItem) {
        self.noteTextView.text = self.detailItem.noteContent;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    self.noteTextView.backgroundColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveEdits:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
}

//
- (void) saveEdits:(id)sender {
    
    if (self.detailItem == nil)
        return;
    
    self.detailItem.noteContent = self.noteTextView.text;
    [self.detailItem saveToURL:self.detailItem.fileURL
              forSaveOperation:UIDocumentSaveForOverwriting
             completionHandler:^(BOOL success) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            self.detailItem = nil;
            self.noteTextView.text = @"";
            [self.noteTextView resignFirstResponder];
            [[NSNotificationCenter defaultCenter] postNotificationName:ItemSavedNotification
                                                                object:nil];
            
        } else {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }];
    
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
