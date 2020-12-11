//
//  PSKGameObject.m
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"

@implementation PSKGameObject

- (void)setFlipX:(BOOL)flipX {
  if (flipX) {
    self.xScale = -fabs(self.xScale);
  } else {
    self.xScale = fabs(self.xScale);
  }
  _flipX = flipX;
}

- (void)setSize:(CGSize)size {
  if (!self.flipX) {
      [super setSize:size];
  } else {
      [super setSize:CGSizeMake(-size.width, size.height)];
  }
}
@end
