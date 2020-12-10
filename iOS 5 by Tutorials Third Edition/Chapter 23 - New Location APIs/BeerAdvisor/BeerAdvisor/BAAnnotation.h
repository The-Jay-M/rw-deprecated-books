//
//  BAAnnotation.h
//  BeerAdvisor
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BAAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end
