//
//  ActionDPad.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ActionDPad.h"
#import "SKTTextureCache.h"

@interface ActionDPad()

@property (assign, nonatomic) CGFloat radius;
@property (strong, nonatomic) NSString *prefix;
@property (assign, nonatomic) ActionDPadDirection previousDirection;
@property (assign, nonatomic) NSUInteger touchHash;

@end

@implementation ActionDPad

+ (instancetype)dPadWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius
{
    return [[self alloc] initWithPrefix:filePrefix
                                 radius:radius];
}

- (instancetype)initWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius
{
    NSString *filename =
    [filePrefix stringByAppendingString:@"_center"];
    
    SKTTextureCache *cache = [SKTTextureCache sharedInstance];
    self = [super initWithTexture:[cache textureNamed:filename]];
    
    if (self) {
        _radius = radius;
        _direction = kActionDPadDirectionCenter;
        _isHeld = NO;
        _prefix = filePrefix;
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

// 1
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchHash == 0)
    {
        for (UITouch *touch in touches) {
            
            CGPoint location = [touch locationInNode:self.parent];
            CGFloat distanceSQ = CGPointDistanceSQ(location,
                                                   self.position);
            
            if (distanceSQ <= self.radius * self.radius) {
                //get angle 8 directions
                self.touchHash = touch.hash;
                [self updateDirectionForTouchLocation:location];
                self.isHeld = YES;
            }
        }
    }
}

// 2
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch.hash == self.touchHash)
        {
            CGPoint location = [touch locationInNode:self.parent];
            [self updateDirectionForTouchLocation:location];
        }
    }
}

// 3
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.direction = kActionDPadDirectionCenter;
    self.isHeld = NO;
    
    for (UITouch *touch in touches) {
        if (touch.hash == self.touchHash)
        {
            NSString *txtName =
            [NSString stringWithFormat:@"%@_center", self.prefix];
            
            SKTexture *texture =
            [[SKTTextureCache sharedInstance] textureNamed:txtName];
            
            [self setTexture:texture];
            [self.delegate actionDPadTouchEnded:self];
            
            self.touchHash = 0;
        }
    }
}


// 4
- (void)update:(NSTimeInterval)delta
{
    if (self.isHeld) {
        [self.delegate actionDPad:self
               isHoldingDirection:self.direction];
    }
}

// 5 & 6
- (void)updateDirectionForTouchLocation:(CGPoint)location
{
    CGPoint point = CGPointSubtract(location, self.position);
    CGFloat radians = CGPointToAngle(point);
    CGFloat degrees = -1 * RadiansToDegrees(radians);
    NSString *suffix = @"_center";
    
    self.previousDirection = self.direction;
    
    if (degrees <= 22.5 && degrees >= -22.5) {
        
        self.direction = kActionDPadDirectionRight;
        suffix = @"_right";
    } else if (degrees > 22.5 && degrees < 67.5) {
        
        self.direction = kActionDPadDirectionDownRight;
        suffix = @"_downright";
    } else if (degrees >= 67.5 && degrees <= 112.5) {
        
        self.direction = kActionDPadDirectionDown;
        suffix = @"_down";
    } else if (degrees > 112.5 && degrees < 157.5) {
        
        self.direction = kActionDPadDirectionDownLeft;
        suffix = @"_downleft";
    } else if (degrees >= 157.5 || degrees <= -157.5) {
        
        self.direction = kActionDPadDirectionLeft;
        suffix = @"_left";
    } else if (degrees < -22.5 && degrees > -67.5) {
        
        self.direction = kActionDPadDirectionUpRight;
        suffix = @"_upright";
    } else if (degrees <= -67.5 && degrees >= -112.5) {
        
        self.direction = kActionDPadDirectionUp;
        suffix = @"_up";
    } else if (degrees < -112.5 && degrees > -157.5) {
        
        self.direction = kActionDPadDirectionUpLeft;
        suffix = @"_upleft";
    }
    
    NSString *textureName =
    [NSString stringWithFormat:@"%@%@", self.prefix, suffix];
    
    [self setTexture:[[SKTTextureCache sharedInstance]
                      textureNamed:textureName]];
    
    if (self.isHeld) {
        
        if (self.previousDirection != self.direction) {
            
            [self.delegate actionDPad:self
                 didChangeDirectionTo:self.direction];
        }
    } else {
        
        [self.delegate actionDPad:self
             didChangeDirectionTo:self.direction];
    }
}


@end
