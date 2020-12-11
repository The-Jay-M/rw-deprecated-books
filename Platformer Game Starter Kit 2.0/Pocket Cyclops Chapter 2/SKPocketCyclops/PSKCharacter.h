//
//  PSKCharacter.h
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"
#import "SKTUtils.h"

@interface PSKCharacter : PSKGameObject

@property (nonatomic, assign) CGPoint velocity;

- (void)update:(NSTimeInterval)dt;

@end
