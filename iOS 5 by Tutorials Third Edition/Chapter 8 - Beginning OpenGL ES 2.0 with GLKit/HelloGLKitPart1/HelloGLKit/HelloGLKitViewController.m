//
//  HelloGLKitViewController.m
//  HelloGLKit
//
//  Created by Main Account on 11/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HelloGLKitViewController.h"

@interface HelloGLKitViewController ()

@end

@implementation HelloGLKitViewController {
    float _curRed;
    BOOL _increasing;
    EAGLContext * _context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _context = [[EAGLContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
}

- (void)cleanup {
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

- (void)dealloc {
    [self cleanup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
        [self cleanup];
    }
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

#pragma mark - GLKViewControllerDelegate

- (void)update {
    if (_increasing) {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
    self.paused = !self.paused;
}

@end
