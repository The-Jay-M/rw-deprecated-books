//
//  AppDelegate.m
//  PocketCyclops
//
//  Created by Jake Gundersen on 9/24/12.
//  Copyright (c) 2012 Jake Gundersen. All rights reserved.
//

#import "AppDelegate.h"
#import "cocos2d.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application {
    if ([CCDirector sharedDirector].view) {
        [[CCDirector sharedDirector] pause];
    }
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    if ([CCDirector sharedDirector].view) {
        [[CCDirector sharedDirector] resume];
    }
}

-(void)applicationDidEnterBackground:(UIApplication*)application {
    if ([CCDirector sharedDirector].view) {
        [[CCDirector sharedDirector] stopAnimation];
    }
}

-(void)applicationWillEnterForeground:(UIApplication*)application {
    if ([CCDirector sharedDirector].view) {
        [[CCDirector sharedDirector] startAnimation];
    }
}

-(void)applicationWillTerminate:(UIApplication *)application {
    if ([CCDirector sharedDirector].view) {
        CCDirector *director = [CCDirector sharedDirector];
        [[director view] removeFromSuperview];
        [director end];
    }
}

-(void)applicationSignificantTimeChange:(UIApplication *)application {
    if ([CCDirector sharedDirector].view) {
        [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    }
}

-(void)dealloc {
    [[CCDirector sharedDirector] end];
}

@end
