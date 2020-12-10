//
//  BAAnnotation.m
//  BeerAdvisor
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "BAAnnotation.h"

@implementation BAAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)c
{
    if (self = [super init]) {
        self.coordinate = c;
    }
    return self;
}
@end
