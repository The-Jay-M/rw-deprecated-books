//
//  DWFParticleView.h
//  DrawWithFire
//
//  Created by Marin Todorov on 25/8/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWFParticleView : UIView

-(void)setEmitterPositionFromTouch: (UITouch*)t;

-(void)setIsEmitting:(BOOL)isEmitting;

@end
