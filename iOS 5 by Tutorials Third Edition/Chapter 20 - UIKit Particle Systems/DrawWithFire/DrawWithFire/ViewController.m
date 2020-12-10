//
//  ViewController.m
//  DrawWithFire
//
//  Created by Marin Todorov on 25/8/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setEmitterPositionFromTouch: [touches anyObject]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setEmitterPositionFromTouch: [touches anyObject]];
    [fireView setIsEmitting:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setIsEmitting:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setIsEmitting:NO];
}

@end
