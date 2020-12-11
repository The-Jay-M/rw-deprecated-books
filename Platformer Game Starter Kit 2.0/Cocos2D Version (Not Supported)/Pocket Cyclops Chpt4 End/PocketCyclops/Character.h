//
//  Character.h
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface Character : GameObject {
    
}

@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround;

-(void)update:(ccTime)dt;
-(CGRect)collisionBoundingBox;

@end
