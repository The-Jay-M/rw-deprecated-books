//
//  MasterViewController.m
//  GuessTheWord
//
//  Created by Marin Todorov on 26/8/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MasterViewController.h"

//Interface declarations
@interface MasterViewController()
{
    int curWord;
    NSArray* objects;
    NSArray* answers;
}
@end

//Implementation declarations
@implementation MasterViewController

-(void)awakeFromNib
{
    self.title = @"Guess the word";
    
    objects = @[@"backpack", @"banana", @"hat", @"pineapple"];
    
    answers = @[
                @[@"backpack", @"bag", @"chair"],
                @[@"orange", @"banana", @"strawberry"],
                @[@"hat", @"head", @"hut"],
                @[@"apple", @"poppler", @"pineapple"],
                ];
    curWord = 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //we show 1 word on each screen
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3; //we show 3 possible answers
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150.0; //the image of the word is 150px high
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = answers[curWord][indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* imgName = [NSString
                         stringWithFormat:@"object_%@.png", objects[curWord] ];
    UIImageView* img = [[UIImageView alloc] initWithImage:
                        [UIImage imageNamed:imgName] ];
    img.frame = CGRectMake(0, 0, 150, 150);
    img.contentMode = UIViewContentModeScaleAspectFit;
    return img;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* word = objects[curWord];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
    if ([word compare: cell.textLabel.text]==NSOrderedSame) {
        //correct
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        //incorrect
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    [self performSelector:@selector(showDefinition:) withObject:cell.textLabel.text afterDelay:1.5];
}

-(void)showDefinition:(NSString*)word
{
    UIReferenceLibraryViewController* dictionaryView = [[UIReferenceLibraryViewController alloc] initWithTerm: word];
    [self presentViewController:dictionaryView animated:YES completion:nil];
    
    //also move to next word
    if (curWord+1 < objects.count) {
        curWord++;
    } else {
        curWord = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

@end
