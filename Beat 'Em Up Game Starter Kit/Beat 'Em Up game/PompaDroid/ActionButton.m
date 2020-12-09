//
//  ActionButton.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ActionButton.h"
#import "SKTTextureCache.h"

@interface ActionButton()

@property (assign, nonatomic) CGFloat radius;
@property (strong, nonatomic) NSString *prefix;
@property (assign, nonatomic) NSUInteger touchHash;

@end

@implementation ActionButton

+ (instancetype)buttonWithPrefix:(NSString *)filePrefix
                          radius:(CGFloat)radius
{
    return [[self alloc] initWithPrefix:filePrefix radius:radius];
}

- (instancetype)initWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius
{
    NSString *filename =
    [filePrefix stringByAppendingString:@"_normal"];
    
    SKTexture *texture =
    [[SKTTextureCache sharedInstance] textureNamed:filename];
    
    self = [super initWithTexture:texture];
    
    if (self) {
        _radius = radius;
        _prefix = filePrefix;
        _isHeld = NO;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)update:(NSTimeInterval)delta
{
    if (self.isHeld) {
        [self.delegate actionButtonIsHeld:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.touchHash == 0)
  {
    for (UITouch *touch in touches) {
            
      CGPoint location = [touch locationInNode:self.parent];
      CGFloat distanceSQ = CGPointDistanceSQ(location,
                                                   self.position);
            
      if (distanceSQ <= self.radius * self.radius) {
        self.touchHash = touch.hash;
        self.isHeld = YES;
                
        NSString *name =
          [NSString stringWithFormat:@"%@_selected", self.prefix];
                
        SKTexture *texture =
        [[SKTTextureCache sharedInstance] textureNamed:name];
                
        [self setTexture:texture];
                
        [self.delegate actionButtonWasPressed:self];
      }
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (self.touchHash == touch.hash)
        {
            self.isHeld = NO;
            self.touchHash = 0;
            NSString *name =
            [NSString stringWithFormat:@"%@_normal", self.prefix];
            
            SKTexture *texture =
            [[SKTTextureCache sharedInstance] textureNamed:name];
            
            [self setTexture:texture];
            
            [self.delegate actionButtonWasReleased:self];
        }
    }
}


@end
