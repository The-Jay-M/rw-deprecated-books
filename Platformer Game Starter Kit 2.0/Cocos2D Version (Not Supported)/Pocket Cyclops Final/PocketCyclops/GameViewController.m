//
//  GameViewController.m
//  Pocket Cyclops
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "GameViewController.h"
#import "GameLevelLayer.h"
#import "SimpleAudioEngine.h"

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize currentLevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CCDirector *director = [CCDirector sharedDirector];
    
    if([director isViewLoaded] == NO)
    {
        // Create the OpenGL view that Cocos2D will render to.
        CCGLView *glView = [CCGLView viewWithFrame:[self.view bounds]
                                       pixelFormat:kEAGLColorFormatRGB565
                                       depthFormat:0];
        
        // Assign the view to the director.
        [director setView:glView];
        [glView setMultipleTouchEnabled:YES];
        // Initialize other director settings.
        [director setAnimationInterval:1.0f/60.0f];
        //[director enableRetinaDisplay:YES];
    }
    
    // Set the view controller as the director's delegate, so we can respond to certain events.
    director.delegate = self;
    
    // Add the director as a child view controller of this view controller.
    [self addChildViewController:director];
    
    // Add the director's OpenGL view as a subview so we can see it.
    [self.view addSubview:director.view];
    [self.view sendSubviewToBack:director.view];
    
    // Finish up our view controller containment responsibilities.
    [director didMoveToParentViewController:self];
    
    // Run whatever scene we'd like to run here.
    if ([director runningScene]) {
        [director replaceScene:[GameLevelLayer sceneWithLevel:currentLevel]];
    } else {
        [director runWithScene:[GameLevelLayer sceneWithLevel:currentLevel]];
    }
	// Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserverForName:@"restart" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [director replaceScene:[CCScene node]];
        [director pause];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    if ([director isPaused]) {
        [director resume];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[CCDirector sharedDirector] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"restart" object:nil];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"restart" object:nil];
}

@end
