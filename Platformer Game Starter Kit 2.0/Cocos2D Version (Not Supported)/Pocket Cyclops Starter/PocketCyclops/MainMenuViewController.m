//
//  MainMenuViewController.m
//  Robots GO TO HELL!
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2012 Interrobang Software LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SimpleAudioEngine.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController
@synthesize playButton;
@synthesize aboutButton;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [playButton setImage:[UIImage imageNamed:@"Play_not_pressed.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"Play_pressed.png"] forState:UIControlStateHighlighted];
    [aboutButton setImage:[UIImage imageNamed:@"About_not_pressed.png"] forState:UIControlStateNormal];	
    [aboutButton setImage:[UIImage imageNamed:@"About_pressed.png"] forState:UIControlStateHighlighted];
	// Start background music
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"mainmenu.mp3"];
    // Do any additional setup after loading the view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end
