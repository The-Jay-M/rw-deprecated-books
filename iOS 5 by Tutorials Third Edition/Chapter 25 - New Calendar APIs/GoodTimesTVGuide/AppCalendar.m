//
//  AppCalendar.m
//  GoodTimesTVGuide
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "AppCalendar.h"

static EKEventStore* eStore = NULL;

@implementation AppCalendar

+(EKEventStore*)eventStore
{
    if (!eStore) {
        eStore = [[EKEventStore alloc] init];
    }
    return eStore;
}


+(EKCalendar*)createAppCalendar
{
    EKEventStore *store = [self eventStore];
    
    //1 fetch the local event store source
    EKSource* localSource = nil;
    for (EKSource* src in store.sources) {
        if (src.sourceType == EKSourceTypeCalDAV) {
            localSource = src;
        }
        if (src.sourceType == EKSourceTypeLocal &&
            localSource==nil) {
            localSource = src;
        }
    }
    
    if (!localSource) return nil;
    
    //2 create a new calendar
    EKCalendar* newCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore: store];
    
    newCalendar.title = kAppCalendarTitle;
    newCalendar.source = localSource;
    newCalendar.CGColor = [[UIColor colorWithRed:0.8 green:0.251
                                            blue:0.6 alpha:1] /*#cc4099*/ CGColor];
    
    //3 save the calendar in the event store
    NSError* error = nil;
    [store saveCalendar: newCalendar commit:YES error:&error];
    if (!error) {
        return nil;
    }
    
    //4 store the calendar id
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    [prefs setValue:newCalendar.calendarIdentifier
             forKey:@"appCalendar"];
    [prefs synchronize];
    
    return newCalendar;
}

+(EKCalendar*)calendar
{
    //1
    EKCalendar* result = nil;
    EKEventStore *store = [self eventStore];
    
    //2 check for a persisted calendar id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *calendarId = [prefs stringForKey:@"appCalendar"];
    
    //3
    if (calendarId && (result =
                       [store calendarWithIdentifier: calendarId]) ) {
        return result;
    }
    
    //4 check for a calendar with the same name
    for (EKCalendar* cal in
         [store calendarsForEntityType:EKEntityTypeEvent]) {
        
        if ([cal.title compare: kAppCalendarTitle]==NSOrderedSame) {
            if (cal.immutable == NO) {
                [prefs setValue:cal.calendarIdentifier
                         forKey:@"appCalendar"];
                [prefs synchronize];
                return cal;
            }
        }
    }
    
    //5 if no calendar is found whatsoever, create one
    result = [self createAppCalendar];
    
    //6
    return result;
}

@end
