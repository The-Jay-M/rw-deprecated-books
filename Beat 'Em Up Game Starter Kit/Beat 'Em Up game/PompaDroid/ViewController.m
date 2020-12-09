//
//  ViewController.m
//  PompaDroid
//
//  Created by Allen Tan on 6/9/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "TitleScene.h"
#import "GameScene.h"
#import "SKTTextureCache.h"
#import "LoadingScene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePresentGameSceneNotification:) name:@"PresentGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePresentTitleSceneNotification:) name:@"PresentTitle" object:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//1
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    
    //2
    if (!skView.scene)
    {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        //3
        skView.showsDrawCount = NO;
        
        //4
        SKScene *titleScene = [TitleScene sceneWithSize:skView.bounds.size];
        [skView presentScene:titleScene];
    }
}

- (void)didReceivePresentTitleSceneNotification:(NSNotification *)notification
{
    SKView *skView = (SKView *)self.view;
    
    SKScene *titleScene =
    [TitleScene sceneWithSize:skView.bounds.size];
    
    [skView presentScene:titleScene
              transition:[SKTransition fadeWithDuration:1.0]];
}

-(void)didReceivePresentGameSceneNotification:(NSNotification *)notification
{
    NSDictionary *attributes = notification.userInfo;
    NSInteger level = [attributes[@"Level"] integerValue];
    
    SKView *skView = (SKView *)self.view;
    //presented loading scene first
    
    SKScene *loadingScene =
    [LoadingScene sceneWithSize:skView.bounds.size];
    
    [skView presentScene:loadingScene
              transition:[SKTransition fadeWithDuration:1.0]];
    
    //added this
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        GameScene *gameScene =
        [GameScene sceneWithSize:skView.bounds.size level:level];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[SKTTextureCache sharedInstance]
             loadTexturesFromAtlas:
             [SKTextureAtlas atlasNamed:@"sprites"]
             filteringMode:SKTextureFilteringNearest];
            
            [skView presentScene:gameScene
                      transition:[SKTransition fadeWithDuration:1.0]];
        });
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PresentTitle" object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"PresentGame" object:nil];
}


@end
