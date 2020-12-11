//
//  AboutViewController.m
//  Robots GO TO HELL!
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2012 Interrobang Software LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "SimpleAudioEngine.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(IBAction)backToMain:(id)sender {
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
