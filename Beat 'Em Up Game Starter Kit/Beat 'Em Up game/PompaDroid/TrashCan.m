//
//  TrashCan.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "TrashCan.h"
#import "SKTTextureCache.h"

@implementation TrashCan

- (instancetype)init
{
    SKTexture *texture =
    [[SKTTextureCache sharedInstance] textureNamed:@"trashcan"];
    
    if (self = [super initWithTexture:texture]) {
        
        self.objectState = kObjectStateActive;
        self.detectionRadius = 57.0 * kPointFactor;
        self.contactPointCount = 5;
        
        self.contactPoints =
        malloc(sizeof(ContactPoint) * self.contactPointCount);
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(0.0, 2.0)
                                 radius:33.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(0.0, -15.0)
                                 radius:33.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointMake(0.0, 26.0)
                                 radius:17.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(19.0, 29.0)
                                 radius:16.0];
        
        [self modifyContactPointAtIndex:4
                                 offset:CGPointMake(-23.0, -38.0)
                                 radius:10.0];
    }
    return self;
}

- (void)destroyed
{
    [self setTexture:[[SKTTextureCache sharedInstance]
                      textureNamed:@"trashcan_hit"]];
    
    [super destroyed];
}

- (CGRect)collisionRect
{
    return CGRectMake(self.position.x - self.size.width/2,
                      self.position.y - self.size.height/2,
                      64 * kPointFactor, 32 * kPointFactor);
}

@end
