//
//  GameScene.m
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import "GameScene.h"
#import "GameLayer.h"
#import "HudLayer.h"
#import "SKTTextureCache.h"
#import "DebugLayer.h"

@interface GameScene()

@property (strong, nonatomic) GameLayer *gameLayer;
@property (strong, nonatomic) HudLayer *hudLayer;
@property (assign, nonatomic) NSTimeInterval lastUpdateTime;

#if DRAW_DEBUG_SHAPES
@property (strong, nonatomic) DebugLayer *debugLayer;
#endif

@end

@implementation GameScene

+ (instancetype)sceneWithSize:(CGSize)size
                        level:(NSUInteger)level
{
    return [[self alloc] initWithSize:size level:level];
}

//added level to the initializer
- (instancetype)initWithSize:(CGSize)size
                       level:(NSUInteger)level
{
    if (self = [super initWithSize:size])
    {
        SKTextureAtlas *atlas =
        [SKTextureAtlas atlasNamed:@"sprites"];
        
        [[SKTTextureCache sharedInstance]
         addTexturesFromAtlas:atlas
         filteringMode:SKTextureFilteringNearest];
        
        [[SKTTextureCache sharedInstance]
         setEnableFallbackSuffixes:YES];
        
        atlas = [SKTextureAtlas atlasNamed:@"joypad"];
        
        [[SKTTextureCache sharedInstance]
         addTexturesFromAtlas:atlas
         filteringMode:SKTextureFilteringLinear];
        
        //added level number
        _gameLayer = [GameLayer nodeWithLevel:level];
        [self addChild:_gameLayer];
        
        _hudLayer = [HudLayer node];
        [self addChild:_hudLayer];
        
        _hudLayer.zPosition = _gameLayer.zPosition + SCREEN.height;
        _hudLayer.dPad.delegate = _gameLayer;
        _gameLayer.hud = _hudLayer;
        
        _hudLayer.buttonA.delegate = _gameLayer;
        _hudLayer.buttonB.delegate = _gameLayer;
        
#if DRAW_DEBUG_SHAPES
        _debugLayer = [DebugLayer nodeWithGameLayer:_gameLayer];
        _debugLayer.zPosition = _gameLayer.zPosition + 1;
        [self addChild:_debugLayer];
#endif
    }
    
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        SKTextureAtlas *atlas =
        [SKTextureAtlas atlasNamed:@"sprites"];
        
        [[SKTTextureCache sharedInstance]
         addTexturesFromAtlas:atlas
         filteringMode:SKTextureFilteringNearest];
        
        [[SKTTextureCache sharedInstance]
         setEnableFallbackSuffixes:YES];
        
        atlas = [SKTextureAtlas atlasNamed:@"joypad"];
        
        [[SKTTextureCache sharedInstance]
         addTexturesFromAtlas:atlas
         filteringMode:SKTextureFilteringLinear];
        
        _gameLayer = [GameLayer node];
        [self addChild:_gameLayer];
        
        _hudLayer = [HudLayer node];
        _hudLayer.zPosition = _gameLayer.zPosition + SCREEN.height;
        [self addChild:_hudLayer];
        
        _hudLayer.dPad.delegate = _gameLayer;
        _gameLayer.hud = _hudLayer;
        
        _hudLayer.buttonA.delegate = _gameLayer;
        _hudLayer.buttonB.delegate = _gameLayer;
        
#if DRAW_DEBUG_SHAPES
        _debugLayer = [DebugLayer nodeWithGameLayer:_gameLayer];
        _debugLayer.zPosition = _gameLayer.zPosition + 1;
        [self addChild:_debugLayer];
#endif

    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    if (self.lastUpdateTime <= 0) {
        self.lastUpdateTime = currentTime;
    }
    
    NSTimeInterval delta = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    
    [self.gameLayer update:delta];
    [self.hudLayer update:delta];
    
#if DRAW_DEBUG_SHAPES
    [self.debugLayer update:delta];
#endif
}

- (void)didMoveToView:(SKView *)view
{
    [self.gameLayer startGame];
}


@end
