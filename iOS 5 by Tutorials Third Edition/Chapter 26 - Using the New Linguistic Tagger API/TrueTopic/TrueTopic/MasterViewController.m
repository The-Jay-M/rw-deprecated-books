//
//  MasterViewController.m
//  TrueTopic
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "RXMLElement.h"
#import "ArticleData.h"

#import "TagWorker.h"
#import "WordCount.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kRSSUrl [NSURL URLWithString: @"http://feeds.feedburner.com/RayWenderlich"]

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _objects = [NSMutableArray array];
    dispatch_async(kBgQueue, ^{
        //work in the background
        RXMLElement *xml = [RXMLElement
                            elementFromURL: kRSSUrl];
        NSArray* items = [[xml child:@"channel"]
                          children:@"item"];
        //iterate over the items
        for (RXMLElement *e in items) {
            //iterate over the articles
            ArticleData* data = [[ArticleData alloc] init];
            data.title = [[e child:@"title"] text];
            data.link = [[e child:@"link"] text];
            [_objects addObject: data ];
        }

        //reload the table
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (ArticleData* data in _objects) {
                TagWorker* worker = [[TagWorker alloc] init];
                [worker get:5 ofRealTopicsAtURL: data.link
                 completion:^(NSArray *words) {
                     data.topic = [words componentsJoinedByString:@" "];
                     //show the real topics
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                     });

                 }];
            }
            
            [self.tableView reloadData];
        });

    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"Cell"
                             forIndexPath:indexPath];
    
    // Fill in the article data
    ArticleData* data = _objects[indexPath.row];
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = data.topic;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
