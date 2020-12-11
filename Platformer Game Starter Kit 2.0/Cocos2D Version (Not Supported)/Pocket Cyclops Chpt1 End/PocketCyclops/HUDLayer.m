//
//  HUDLayer.m
//  ManOfPac
//
//  Created by Jacob Gundersen on 12/7/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//

#import "HUDLayer.h"

#import "GameViewController.h"
#import "SimpleAudioEngine.h"
#import "iCadeReaderView.h"


@interface HUDLayer() <iCadeEventDelegate> {
    iCadeReaderView *icrv;
    
    CCSprite *leftButton;
    CCSprite *rightButton;
    CCSprite *jumpButton;
    CCSprite *pauseButton;
    
    BOOL LEFTPRESSED;
    BOOL RIGHTPRESSED;
    BOOL JUMPPRESSED;
    
    NSArray *buttons;
    CCSprite *lifeMeter;
}

@end

@implementation HUDLayer

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        self.isTouchEnabled = YES;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLifeMeter:) name:@"LifeUpdate" object:nil];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"hud.png"];
        [self addChild:spriteSheet];
        
        lifeMeter = [CCSprite spriteWithSpriteFrameName:@"Life_Bar_5_5.png"];
        
        lifeMeter.position = ccp(70, 290);
        
        [self addChild:lifeMeter];
        
        leftButton = [CCSprite spriteWithSpriteFrameName:@"leftButton.png"];
        rightButton = [CCSprite spriteWithSpriteFrameName:@"rightButton.png"];
        jumpButton = [CCSprite spriteWithSpriteFrameName:@"jumpButton.png"];
        
        buttons = [[NSArray alloc ] initWithObjects:leftButton,
                   rightButton, 
                   jumpButton,  
                   nil];
        
        
        leftButton.position = ccp(50, 50);
        rightButton.position = ccp(130, 50);
        //winsize returns portrait size - so we use height to position right button
        jumpButton.position = ccp(winSize.height - 50, 50);
        
        
        [self addChild:jumpButton];
        [self addChild:leftButton];
        [self addChild:rightButton];
        
        
        icrv = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
        UIView *root = [[CCDirector sharedDirector] view];
        [root addSubview:icrv];
        icrv.active = YES;
        icrv.delegate = self;
        
	}
	return self;
}

-(void)setLifeMeter:(NSNotification *)note {
    float pct = [[[note userInfo] objectForKey:@"life"] floatValue];
    int num = (int)(pct * 5);
    NSLog(@"num %d, %f", num, pct);
    NSString *lifeFrame = [NSString stringWithFormat:@"Life_Bar_%d_5.png", num];
    [lifeMeter setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:lifeFrame]];
}

//these methods are used to query the state of on screen controller

-(joystickDirection)getJoystickDirection {
    if (LEFTPRESSED) {
        return kJoyDirectionLeft;
    } else if (RIGHTPRESSED) {
        return kJoyDirectionRight;
    } else {
        return kJoyDirectionNone;
    }
}

-(jumpButtonState)getJumpButtonState {
    if (JUMPPRESSED) {
        return kJumpButtonOn;
    } else {
        return kJumpButtonOff;
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    for (UITouch *t in touches) {
        
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        for (CCSprite *s in buttons) {
            if (CGRectContainsPoint(s.boundingBox, touchLocation)) {
                int buttIndex = [buttons indexOfObject:s];
                if (buttIndex == 2) {
                    [self sendJump:YES];
                } else if (buttIndex == 1) {
                    [self sendDirection:kJoyDirectionRight];
                    
                } else if (buttIndex == 0) {
                    [self sendDirection:kJoyDirectionLeft];
                    
                }
                
            } 
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        //get previous touch and convert it to node space
        CGPoint previousTouchLocation = [t previousLocationInView:[t view]];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        previousTouchLocation = ccp(previousTouchLocation.x, screenSize.height - previousTouchLocation.y);
        
        for (CCSprite *s in buttons) {
            if (CGRectContainsPoint(s.boundingBox, previousTouchLocation) && 
                !CGRectContainsPoint(s.boundingBox, touchLocation)) {
                
                
                int buttIndex = [buttons indexOfObject:s];
                
                if (buttIndex == 0) {
                    [self sendDirection:kJoyDirectionNone];
                    
                } else if (buttIndex == 1) {
                    [self sendDirection:kJoyDirectionNone];
                    
                } else if (buttIndex == 2) {
                    [self sendJump:NO];
                    
                } 
            }
        }
        
        for (CCSprite *s in buttons) {
            if (!CGRectContainsPoint(s.boundingBox, previousTouchLocation) && 
                CGRectContainsPoint(s.boundingBox, touchLocation)) {
                
                
                int buttIndex = [buttons indexOfObject:s];
                
                //We don't get another jump on a slide on, we want the player to let go of the button for another jump
                if (buttIndex == 1) {
                    [self sendDirection:kJoyDirectionRight];
                    
                } else if (buttIndex == 0) {
                    [self sendDirection:kJoyDirectionLeft];
                    
                }
                
            } 
        } 
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *t in touches) {
        
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        for (CCSprite *s in buttons) {
            if (CGRectContainsPoint(s.boundingBox, touchLocation)) {
                
                int buttIndex = [buttons indexOfObject:s];
                
                if (buttIndex == 0) {
                    [self sendDirection:kJoyDirectionNone];
                   
                } else if (buttIndex == 1) {
                    [self sendDirection:kJoyDirectionNone];
                  
                } else if (buttIndex == 2) {
                    [self sendJump:NO];
                    
                } else if (buttIndex == 3) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:nil];
                    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
                }
            }
        }
    }
}

#pragma mark osc controller methods

-(void)sendJump:(BOOL)jumpOn {
    if (jumpOn) {
        JUMPPRESSED = YES;
        [jumpButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpButtonPressed.png"]];
    } else {
        JUMPPRESSED = NO;
        [jumpButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpButton.png"]];
    }
}

-(void)sendDirection:(joystickDirection)direction {
    if (direction == kJoyDirectionLeft) {
        LEFTPRESSED = YES;
        [leftButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftButtonPressed.png"]];
        RIGHTPRESSED = NO;
        [rightButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rightButton.png"]];
    } else if (direction == kJoyDirectionRight) {
        RIGHTPRESSED = YES;
        [rightButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rightButtonPressed.png"]];
        LEFTPRESSED = NO;
        [leftButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftButton.png"]];
    } else {
        RIGHTPRESSED = NO;
        [rightButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rightButton.png"]];
        LEFTPRESSED = NO;
        [leftButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftButton.png"]];
    }
}

#pragma mark iCade Methods
//this just sends the incoming buttons through our osc handling logic

-(void)buttonDown:(iCadeState)button {
    //NSLog(@"iCade Button Press, %d", button);
    if (button == iCadeJoystickLeft) {
        [self sendDirection:kJoyDirectionLeft];
    } else if (button == iCadeJoystickRight) {
        [self sendDirection:kJoyDirectionRight];
    } else if (button == iCadeButtonA || 
               button == iCadeButtonB || 
               button == iCadeButtonC || 
               button == iCadeButtonD || 
               button == iCadeButtonE || 
               button == iCadeButtonF || 
               button == iCadeButtonG || 
               button == iCadeButtonH) {
        [self sendJump:YES];
    } 
}

-(void)buttonUp:(iCadeState)button {
    if (button == iCadeJoystickLeft || button == iCadeJoystickRight) {
        [self sendDirection:kJoyDirectionNone];
    } else if (button == iCadeButtonA || 
               button == iCadeButtonB || 
               button == iCadeButtonC || 
               button == iCadeButtonD || 
               button == iCadeButtonE || 
               button == iCadeButtonF || 
               button == iCadeButtonG || 
               button == iCadeButtonH) {
        [self sendJump:NO];
    } 
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LifeUpdate" object:nil ];
}

@end
