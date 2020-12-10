//
//  ViewController.m
//  BeerAdvisor
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "BAAnnotation.h"

@interface ViewController()<CLLocationManagerDelegate>
{
    IBOutlet MKMapView* map;
    IBOutlet UILabel* locationLabel;
    IBOutlet UILabel* addressLabel;
    CLLocationManager* manager;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //start updating the location
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    [manager startUpdatingLocation];
    
    
    //monitor for the Kreuzberg neighbourhood
    //1
    CLLocationCoordinate2D kreuzbergCenter;
    kreuzbergCenter.latitude = 52.497727;
    kreuzbergCenter.longitude = 13.431129;
    //2
    CLCircularRegion* kreuzberg = [[CLCircularRegion alloc] initWithCenter:kreuzbergCenter
                                                                    radius:1000
                                                                identifier:@"Kreuzberg"];
    //3
    [manager startMonitoringForRegion: kreuzberg];

}

-(void)dealloc
{
    [manager stopUpdatingLocation];
    
    for (CLRegion* region in manager.monitoredRegions) {
        [manager stopMonitoringForRegion: region];
    }

}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    [[[UIAlertView alloc] initWithTitle:@"Kreuzberg, Berlin"
                                message:@"Awesome place for beer, just hop in any bar!"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.coordinate.latitude !=
        oldLocation.coordinate.latitude) {
        [self revGeocode: newLocation];
    }
}

-(void)revGeocode:(CLLocation*)c
{
    //reverse geocoding demo, coordinates to an address
    addressLabel.text = @"reverse geocoding coordinate ...";
    CLGeocoder* gcrev = [[CLGeocoder alloc] init];
    
    [gcrev reverseGeocodeLocation:c completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         CLPlacemark* revMark = [placemarks objectAtIndex:0];
         //turn placemark to address text
         NSArray* addressLines = revMark.addressDictionary[@"FormattedAddressLines"];
         
         NSString* revAddress = [addressLines componentsJoinedByString: @"\n"];
         
         addressLabel.text = [NSString stringWithFormat:
                              @"Reverse geocoded address: \n%@", revAddress];
         
         //now turn the address to coordinates
         [self geocode: revAddress];
     }];
}

-(void)geocode:(NSString*)address
{
    locationLabel.text = @"geocoding address...";
    CLGeocoder* gc  = [[CLGeocoder alloc] init];
    
    //2
    [gc geocodeAddressString:address completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         //3
         if ([placemarks count]>0) { //4
             CLPlacemark* mark = (CLPlacemark*)placemarks[0];
             double lat = mark.location.coordinate.latitude;
             double lng = mark.location.coordinate.longitude;
             
             //5 show the coords text
             locationLabel.text = [NSString stringWithFormat:
                                   @"Cordinate lat: %@, long: %@",
                                   [NSNumber numberWithDouble: lat],
                                   [NSNumber numberWithDouble: lng]];
             //show on the map
             //1
             CLLocationCoordinate2D coordinate;
             coordinate.latitude = lat;
             coordinate.longitude = lng;
             //2
             [map addAnnotation:[[BAAnnotation alloc]
                                 initWithCoordinate:coordinate] ];
             //3
             MKCoordinateRegion viewRegion =
             MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
             MKCoordinateRegion adjustedRegion = [map 
                                                  regionThatFits:viewRegion];
             
             [map setRegion:adjustedRegion animated:YES];

         } 
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
