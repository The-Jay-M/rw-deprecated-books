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

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (strong, nonatomic) NSMutableArray *notes;

- (void)loadDocument;

extern NSString * const ItemSavedNotification;

@end
