//
//  PSKViewController.m
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKGameViewController.h"
#import "PSKLevelScene.h"

@interface PSKGameViewController ()
@property (nonatomic, strong) NSMutableArray *observers;
@end

@implementation PSKGameViewController

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  [self setupObservers];

  // Configure the view.
  SKView *skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
  // Create and configure the scene.
  PSKLevelScene *scene = [PSKLevelScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;

  // Present the scene.
  [skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskLandscape;
}

- (void)setupObservers {
  self.observers = [NSMutableArray array];

  id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    SKView *skView = (SKView *)self.view;
    skView.paused = YES;
  }];
  [self.observers addObject:observer];
  
  observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    SKView *skView = (SKView *)self.view;
    skView.paused = YES;
  }];
  [self.observers addObject:observer];
  
  observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    SKView *skView = (SKView *)self.view;
    skView.paused = NO;
  }];
  [self.observers addObject:observer];
}

- (void)dealloc {
  for (id observer in self.observers) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
  }
}

@end
