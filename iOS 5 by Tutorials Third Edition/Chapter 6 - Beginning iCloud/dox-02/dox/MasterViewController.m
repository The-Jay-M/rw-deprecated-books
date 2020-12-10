//
//  MasterViewController.m
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}

@property (nonatomic, strong) NSIndexPath *selectedPath;

- (void)loadData:(NSMetadataQuery *)query;

@end

NSString * const ItemSavedNotification =  @"itemSaved";

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

//
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.notes = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDocument)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearSelection:)
                                                     name:ItemSavedNotification
                                                   object:nil];
    }
}

- (void) clearSelection:(NSNotification *) notification {

    [self.tableView deselectRowAtIndexPath:self.selectedPath
                                  animated:YES];
    self.selectedPath = nil;
    
}

- (void)loadDocument {
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq) {
        
        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:
         [NSArray arrayWithObject:
          NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"%K like 'Note_*'", NSMetadataItemFSNameKey];
        [self.query setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:self.query];
        
        [self.query startQuery];
        
    } else {
        
        NSLog(@"No iCloud access");
        
    }
    
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    self.query = nil;
    
}


- (void)loadData:(NSMetadataQuery *)query {
    
    [self.notes removeAllObjects];
    
    for (NSMetadataItem *item in [query results]) {
        
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        Note *doc = [[Note alloc] initWithFileURL:url];
        
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                
                [self.notes addObject:doc];
                [self.tableView reloadData];
                
            } else {
                NSLog(@"failed to open from iCloud");
            }
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//
- (void)insertNewObject:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"Note_%@",
                          [formatter stringFromDate:[NSDate date]]];
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    NSURL *ubiquitousPackage =
    [[ubiq URLByAppendingPathComponent:@"Documents"]
     URLByAppendingPathComponent:fileName];
    
    Note *doc = [[Note alloc] initWithFileURL:ubiquitousPackage];
    
    [doc saveToURL:[doc fileURL]
  forSaveOperation:UIDocumentSaveForCreating
 completionHandler:^(BOOL success) {
     
     if (success) {
         
         [self.notes addObject:doc];
         [self.tableView reloadData];
         
     }
     
 }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Note * note = self.notes[indexPath.row];
    cell.textLabel.text = note.fileURL.lastPathComponent;
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        Note *selectedNote = self.notes[indexPath.row];
        self.detailViewController.detailItem = selectedNote;
        self.selectedPath = indexPath;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Note *selectedNote = self.notes[indexPath.row];
        self.detailViewController.detailItem = selectedNote;
        [[segue destinationViewController] setDetailItem:selectedNote];
        
    }
}

@end
