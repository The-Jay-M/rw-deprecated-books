//
//  Hero.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ActionSprite.h"
#import "Weapon.h"

@interface Hero : ActionSprite <WeaponDelegate>

@property (strong, nonatomic) SKAction *attackTwoAction;
@property (strong, nonatomic) SKAction *attackThreeAction;
@property (assign, nonatomic) CGFloat attackTwoDamage;
@property (assign, nonatomic) CGFloat attackThreeDamage;
@property (weak, nonatomic) Weapon *weapon;

- (void)dropWeapon;
- (BOOL)pickUpWeapon:(Weapon *)weapon;

@end
