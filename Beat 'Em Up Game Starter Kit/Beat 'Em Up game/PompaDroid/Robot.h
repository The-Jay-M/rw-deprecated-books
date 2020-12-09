//
//  Robot.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ActionSprite.h"

@interface Robot : ActionSprite

@property (strong, nonatomic) SKSpriteNode *belt;
@property (strong, nonatomic) SKSpriteNode *smoke;
@property (assign, nonatomic) ColorSet colorSet;

@end
