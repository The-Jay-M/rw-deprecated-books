//
//  LevelSelectViewController.m
//  Robots GO TO HELL!
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2012 Interrobang Software LLC. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "GameViewController.h"
#import "SimpleAudioEngine.h"

@interface LevelSelectViewController () {
	float screenWidth;
}

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UIButton *level1Button;
@property (strong, nonatomic) IBOutlet UIButton *level2Button;
@property (strong, nonatomic) IBOutlet UIButton *level3Button;
@property (strong, nonatomic) IBOutlet UIButton *level4Button;
@property (strong, nonatomic) IBOutlet UIButton *level5Button;

- (IBAction)backToMain:(id)sender;

@end

@implementation LevelSelectViewController

@synthesize pageControl;
@synthesize scroller;
@synthesize level1Button;
@synthesize level2Button;
@synthesize level3Button;
@synthesize level4Button;
@synthesize level5Button;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	screenWidth = self.view.frame.size.width;
    scroller.contentSize = CGSizeMake(screenWidth * 3, 320);
	// Set the first level to the center of the screen
	CGRect r = level1Button.frame;
	float x = (screenWidth - r.size.width) * 0.5f;
	r.origin.x = x;
	level1Button.frame = r;
	// Set the buttons apart by a screen's width
	r = level2Button.frame;
	x += screenWidth;
	r.origin.x = x;
	level2Button.frame = r;
	r = level3Button.frame;
	x += screenWidth;
	r.origin.x = x;
	level3Button.frame = r;
	// Enable pagination
    scroller.pagingEnabled = YES;
    //The code below is included for reference. It's a method for making levels unselectable
    //until they have been completed. Set the levels (except the first) to an opaticy of 0.5 and
    //desleect userInteractionEnabled in the UIStoryboard.
    
    //Then after the user completes the level, set the levelUnlocked key in the NSUserDefaults to the
    //next level number.
    /*
    NSArray *lvlsAr = [NSArray arrayWithObjects:level1Button, level2Button, level3Button, nil];
    
    NSNumber *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"levelUnlocked"];
    int level;
    
    if (num == nil) {
        level = 1;
    } else {
        level = [num intValue];
    }
    
    for (int i = 0; i < level; i++) {
        UIButton *b = [lvlsAr objectAtIndex:i];
        b.userInteractionEnabled = YES;
        b.alpha = 1.0;
    }
     */
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = (int)(scroller.contentOffset.x / screenWidth + 0.5);
	//    NSLog(@"current page %d", pageControl.currentPage);
}

-(IBAction)backToMain:(id)sender {
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)toGameView:(id)sender {
	[[SimpleAudioEngine sharedEngine] playEffect:@"menu.wav"];
    [self performSegueWithIdentifier:@"ToGameView" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToGameView"]) {
        GameViewController  *gvc = segue.destinationViewController;
        UIButton *b = (UIButton *)sender;
        NSString *lvlText = b.titleLabel.text;
        gvc.currentLevel = [[lvlText substringFromIndex:5] intValue];
    }
}

@end
