//
//  DamageNumber.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/15/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DamageNumber : CCLabelBMFont {
    
}

@property(nonatomic, strong)id damageAction;

-(void)showWithValue:(int)value fromOrigin:(CGPoint)origin;

@end
