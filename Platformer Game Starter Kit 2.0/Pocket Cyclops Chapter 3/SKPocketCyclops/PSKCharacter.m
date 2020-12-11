//
//  PSKCharacter.m
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKCharacter.h"

@implementation PSKCharacter

- (void)update:(NSTimeInterval)dt {
  //override this method
}

- (CGRect)collisionBoundingBox {
  CGPoint diff = CGPointSubtract(self.desiredPosition, self.position);
  return CGRectOffset(self.frame, diff.x, diff.y);
}

@end
