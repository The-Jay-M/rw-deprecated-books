//
//  LoadingScene.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "LoadingScene.h"

@implementation LoadingScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        SKLabelNode *loadingLabel =
        [SKLabelNode labelNodeWithFontNamed:@"04b03"];
        
        loadingLabel.fontSize = 40 * kPointFactor;
        
        loadingLabel.horizontalAlignmentMode =
        SKLabelHorizontalAlignmentModeLeft;
        
        loadingLabel.text = @"Loading...";
        
        loadingLabel.position =
        CGPointMake(SCREEN.width - 185 * kPointFactor,
                    20 * kPointFactor);
        
        [self addChild:loadingLabel];
    }
    
    return self;
}

@end
