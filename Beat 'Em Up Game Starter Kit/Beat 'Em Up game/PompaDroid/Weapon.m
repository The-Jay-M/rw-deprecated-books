//
//  Weapon.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "Weapon.h"
#import "SKTTextureCache.h"

@implementation Weapon

- (NSMutableArray *)texturesWithPrefix:(NSString *)prefix
                         startFrameIdx:(NSUInteger)startFrameIdx
                            frameCount:(NSUInteger)frameCount
{
    NSUInteger idxCount = frameCount + startFrameIdx;
    
    NSMutableArray *textures =
    [NSMutableArray arrayWithCapacity:frameCount];
    
    SKTexture *texture;
    
    for (NSUInteger i  = startFrameIdx; i < idxCount; i++) {
        
        texture = [[SKTTextureCache sharedInstance] textureNamed:[NSString stringWithFormat:@"%@_%02lu", prefix, (unsigned long)i]];
        
        [textures addObject:texture];
    }
    
    return textures;
}

- (AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount timePerFrame:(NSTimeInterval)timePerFrame target:(id)target
{
    NSMutableArray *textures =
    [self texturesWithPrefix:prefix
               startFrameIdx:startFrameIdx
                  frameCount:frameCount];
    
    AnimationMember *animationMember =
    [AnimationMember animationWithTextures:textures
                                    target:target];
    
    return animationMember;
}

- (void)cleanup
{
    self.droppedAction = nil;
    self.destroyedAction = nil;
    self.attack = nil;
    self.attackTwo = nil;
    self.attackThree = nil;
    self.idle = nil;
    self.walk = nil;
}

- (void)reset
{
    self.hidden = YES;
    self.shadow.hidden = YES;
    self.weaponState = kWeaponStateNone;
    self.velocity = CGPointZero;
    self.jumpVelocity = 0;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.shadow.hidden = hidden;
}

- (void)setGroundPosition:(CGPoint)groundPosition
{
    _groundPosition = groundPosition;
    self.shadow.position = CGPointMake(groundPosition.x, groundPosition.y - self.centerToBottom);
    
}

- (void)used
{
    self.limit--;
    
    if (self.limit <= 0) {
        [self.delegate weaponDidReachLimit:self];
        self.weaponState = kWeaponStateDestroyed;
        [self runAction:self.destroyedAction];
    }
}

- (void)pickedUp
{
    self.weaponState = kWeaponStateEquipped;
    self.shadow.hidden = YES;
}

- (void)droppedFrom:(CGFloat)height to:(CGPoint)destination
{
    self.jumpVelocity = kJumpCutoff;
    self.jumpHeight = height;
    self.groundPosition = destination;
    self.weaponState = kWeaponStateUnequipped;
    self.shadow.hidden = NO;
    [self runAction:self.droppedAction];
}

- (void)update:(NSTimeInterval)delta
{
    
    if (self.weaponState > kWeaponStateEquipped) {
        
        self.groundPosition =
        CGPointAdd(self.groundPosition,
                   CGPointMultiplyScalar(self.velocity, delta));
        
        self.jumpVelocity -= kGravity * delta;
        self.jumpHeight += self.jumpVelocity * delta;
        
        if (self.jumpHeight < 0) {
            self.velocity = CGPointZero;
            self.jumpVelocity = 0;
            self.jumpHeight = 0;
        }
    }
}

- (void)setTexture:(SKTexture *)texture
{
    // 1
    CGFloat xScale = self.xScale;
    CGFloat yScale = self.yScale;
    
    // 2
    self.xScale = 1.0;
    self.yScale = 1.0;
    
    [super setTexture:texture];
    
    // 3
    self.size = texture.size;
    
    //restore the previous xScale
    self.xScale = xScale;
    self.yScale = yScale;
}

@end
