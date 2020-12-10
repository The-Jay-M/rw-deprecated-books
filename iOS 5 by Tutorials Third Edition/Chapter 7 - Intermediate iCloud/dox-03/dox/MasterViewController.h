//
//  MasterViewController.h
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (strong, nonatomic) NSMutableArray *notes;
@property (strong, nonatomic) UISwitch *cloudSwitch;
@property (assign, nonatomic) BOOL useiCloud;

- (void)loadDocument;

extern NSString * const ItemSavedNotification;

@end
