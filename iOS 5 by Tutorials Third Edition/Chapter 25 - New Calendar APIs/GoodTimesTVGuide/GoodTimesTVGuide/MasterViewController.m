//
//  MasterViewController.m
//  GoodTimesTVGuide
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MasterViewController.h"
#import <EventKitUI/EventKitUI.h> //1

#import "AppCalendar.h"

@interface MasterViewController() <UIAlertViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate>
{
    NSArray* shows; //2
}
@end

@implementation MasterViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Good Times TV Guide"; //3
    
    //4
    NSString* listPath = [[NSBundle mainBundle].resourcePath
                          stringByAppendingPathComponent:@"showList.plist"];
    shows = [NSArray arrayWithContentsOfFile: listPath];
    
    [[AppCalendar eventStore]
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {
         
         NSLog(@"Permission is granted : %@", (granted)?@"YES":@"NO");
     }];
}

#pragma mark - Table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    NSDictionary* show = shows[indexPath.row];
    cell.textLabel.text = show[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[UIAlertView alloc] initWithTitle:@"Import tv show schedule"
                                message:@"Do you want to import to:"
                               delegate:self
                      cancelButtonTitle:@"Existing calendar"
                      otherButtonTitles:@"TV Guide's calendar", nil] show];
}

#pragma mark - Alertview delegate
-(void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        //show calendar chooser view controller
        EKCalendarChooser* chooseCal = [[EKCalendarChooser alloc]
                                        initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
                                        displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
                                        eventStore:[AppCalendar eventStore]];
        
        chooseCal.delegate = self;
        chooseCal.showsDoneButton = YES;
        
        [self.navigationController pushViewController:chooseCal 
                                             animated:YES];

    } else {
        //use the app's default calendar
        int row = [self.tableView indexPathForSelectedRow].row;
        [self addShow:shows[row]
           toCalendar:[AppCalendar calendar]];
    }
}

#pragma mark - Calendar methods
-(void)addShow:(NSDictionary*)show toCalendar:(EKCalendar*)calendar
{
    EKEvent* event = [EKEvent eventWithEventStore:
                      [AppCalendar eventStore]];
    event.calendar = calendar;

    EKAlarm* myAlarm = [EKAlarm alarmWithRelativeOffset: - 06*60];
    [event addAlarm: myAlarm];
    
    
    NSDateFormatter* frm = [[NSDateFormatter alloc] init];
    [frm setDateFormat:@"MM/dd/yyyy HH:mm zzz"];
    [frm setLocale:[[NSLocale alloc]
                    initWithLocaleIdentifier:@"en_US"]];
    event.startDate = [frm dateFromString: show[@"startDate"]];
    event.endDate = [frm dateFromString: show[@"endDate"]];
 
    
    event.title = show[@"title"];
    event.URL = [NSURL URLWithString:show[@"url"]];
    event.location = @"The living room";
    event.notes = show[@"tip"];
    
    
    NSNumber* weekDay = [show objectForKey:@"dayOfTheWeek"]; //1
    
    EKRecurrenceDayOfWeek* showDay =
    [EKRecurrenceDayOfWeek dayOfWeek: [weekDay intValue]];
    
    //2
    EKRecurrenceEnd* runFor3Months =
    [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:12];
    
    //3
    EKRecurrenceRule* myReccurrence = [[EKRecurrenceRule alloc]
                                       initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                       interval:1
                                       daysOfTheWeek:@[showDay]
                                       daysOfTheMonth:nil
                                       monthsOfTheYear:nil
                                       weeksOfTheYear:nil
                                       daysOfTheYear:nil
                                       setPositions:nil
                                       end:runFor3Months];
    
    [event addRecurrenceRule: myReccurrence];
    
    //1 save the event to the calendar
    NSError* error = nil;
    
    [[AppCalendar eventStore] saveEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    
    //2 show the edit event dialogue
    EKEventEditViewController* editEvent =
    [[EKEventEditViewController alloc] init];
    
    editEvent.eventStore = [AppCalendar eventStore];
    editEvent.event = event;
    editEvent.editViewDelegate = self;
    
    [self presentViewController:editEvent animated:YES completion:^{
        
        UINavigationItem* item = [editEvent.navigationBar.items
                                  objectAtIndex:0];
        item.leftBarButtonItem = nil;
    }];
    
    
}

#pragma mark - Edit event delegate
-(EKCalendar*)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return [AppCalendar calendar];
}

- (void)eventEditViewController: (EKEventEditViewController *)controller
          didCompleteWithAction: (EKEventEditViewAction)action
{
    NSError* error = nil;
    switch (action) {
        case EKEventEditViewActionDeleted:
            [[AppCalendar eventStore] removeEvent:controller.event
                                             span:EKSpanFutureEvents error:&error];
        default:break;
    }
    
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

#pragma mark - Calendar chooser delegate
- (void)calendarChooserDidFinish:
(EKCalendarChooser*)calendarChooser
{
    //1
    EKCalendar* selectedCalendar =
    [calendarChooser.selectedCalendars anyObject];
    
    //2
    int row = [self.tableView indexPathForSelectedRow].row;
    
    //3
    [self addShow: [shows objectAtIndex:row]
       toCalendar: selectedCalendar];
    
    //4
    [self.navigationController popViewControllerAnimated:YES];
}


@end
