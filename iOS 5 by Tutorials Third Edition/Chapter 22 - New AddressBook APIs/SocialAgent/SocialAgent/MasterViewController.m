//
//  MasterViewController.m
//  SocialAgent
//
//  Created by Marin Todorov on 28/8/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MasterViewController.h"

#import <AddressBook/AddressBook.h> //1

#define kBgQueue dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //2

#define kContactsList [NSURL URLWithString: @"http://www.touch-code-magazine.com/services/ContactsDemo/"] //3

@interface MasterViewController()
{
    NSArray* contacts; //4
}
-(void)importContacts; //5
@end

@implementation MasterViewController

-(void)awakeFromNib
{
    self.title = @"Social Agent"; //1
    self.tableView.allowsMultipleSelection = YES; //2
    
    //3
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import selected" style:UIBarButtonItemStyleDone target:self action:@selector(importContacts)];
    
    //read directory here
    dispatch_async(kBgQueue , ^{
        contacts = [NSArray arrayWithContentsOfURL: kContactsList];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
        });
    });

}

-(void)viewDidAppear:(BOOL)animated
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        //ask access
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            //the user responded
        });
    }
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        //access was already granted
        [[[UIAlertView alloc]
          initWithTitle: @"Access denied!"
          message: @"No access to address book. This app won't work"
          delegate: nil
          cancelButtonTitle:@"Close"
          otherButtonTitles:nil] show];
    }
    
    CFBridgingRelease(addressBook);
}

-(void)importContacts
{
    NSArray* selectedCells = [self.tableView indexPathsForSelectedRows]; //1
    
    if (!selectedCells) return; //2
    
    NSMutableString* ids = [NSMutableString stringWithString:@""];
    for (NSIndexPath* path in selectedCells) {
        [ids appendFormat:@"%i,", path.row]; //3
    }
    
    NSLog(@"selected: %@", ids); //4
    
    
    dispatch_async(kBgQueue , ^{
        NSString* request = [NSString stringWithFormat:@"%@?%@",
                             kContactsList, ids]; //1
        
        NSData* responseData = [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:request]]; //2
        //parse vCard data
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil); //1
        
        ABRecordRef record = ABPersonCreate(); //2
        NSArray* importedPeople = (__bridge_transfer NSArray*)
        ABPersonCreatePeopleInSourceWithVCardRepresentation( record, (__bridge CFDataRef)responseData); //3
        CFBridgingRelease(record); //4

        //define few constants
        __block NSMutableString* message = [NSMutableString stringWithString: @"Contacts are imported to your Address Book. Also you can add them in Facebook: "];
        
        NSString* serviceKey = (NSString*)kABPersonSocialProfileServiceKey;
        
        NSString* facebookValue = (NSString*)kABPersonSocialProfileServiceFacebook;
        
        NSString* usernameKey = (NSString*)kABPersonSocialProfileUsernameKey;
        
        //loop over people and get their facebook
        for (int i=0;i<[importedPeople count];i++) { //1
            ABRecordRef personRef = (__bridge ABRecordRef)
            importedPeople[i];
            ABAddressBookAddRecord(addressBook, personRef, nil);
            
            //2
            ABMultiValueRef profilesRef = ABRecordCopyValue( personRef,
                                                            kABPersonSocialProfileProperty);
            NSArray* profiles = (__bridge_transfer NSArray*)
            ABMultiValueCopyArrayOfAllValues(profilesRef);
            
            //3
            for (NSDictionary* profile in profiles) { //4
                NSString* curServiceValue = profile[serviceKey]; //5
                if ([facebookValue compare: curServiceValue]
                    == NSOrderedSame) { //6
                    
                    [message appendFormat: @"%@, ", profile[usernameKey]];
                } 
            }
            
            //7
            CFBridgingRelease(profilesRef);
        }

        //save to addressbook
        ABAddressBookSave(addressBook, nil);
        CFBridgingRelease(addressBook);
        
        //show done alert
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle: @"Done!"
              message: message
              delegate: nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil] show];
        });

    });

}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1; //we'll need only 1 section
}

-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    return contacts.count; //contacts is our data source
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           contacts[indexPath.row][@"name"],
                           contacts[indexPath.row][@"family"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* selected = [self.tableView
                         indexPathsForSelectedRows];
    self.title = [NSString stringWithFormat:
                  @"%i items",selected.count];
}

-(void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* selected = [self.tableView
                         indexPathsForSelectedRows];
    self.title = [NSString stringWithFormat:
                  @"%i items",selected.count];
}

@end
