//
//  ViewController.m
//  GameCenterDemo
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()
{
    IBOutlet UIImageView* photoView;
    IBOutlet UILabel* nameLabel;
}
-(IBAction)achieveRightNow;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([GKLocalPlayer localPlayer].authenticated == NO) { //1
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:
         ^(UIViewController *controller, NSError *error) {
             
             if (!error && controller) {
                 [self presentViewController:controller animated:YES completion:^{
                     if ([GKLocalPlayer localPlayer].isAuthenticated)
                     {
                         [self updateUI];
                     }
                 }];
                 return;
             }
             
             [self updateUI];
             
         }];
    }
}

-(void)updateUI
{
    // your code if authenticated
    nameLabel.text = [GKLocalPlayer localPlayer].alias; //4
    
    //show the user photo
    [self loadPlayerPhoto];
    
    //show logged notification
    [self showMessage:@"User authenticated successfuly"];
}

-(void)loadPlayerPhoto
{
    [[GKLocalPlayer localPlayer]loadPhotoForSize:GKPhotoSizeNormal
                           withCompletionHandler: ^(UIImage *photo, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^(void) {
                                   if (error==nil) {
                                       photoView.image = photo; //show photo notification later
                                       [self showMessage:@"Photo downloaded"];
                                   } else {
                                       nameLabel.text = @"No player photo"; }
                               });
                           }];
}

//add inside the implementation
-(void)showMessage:(NSString*)msg {
    [GKNotificationBanner showBannerWithTitle:@"GameKit message"
                                      message:msg
                            completionHandler:^{}];
}

-(IBAction)achieveRightNow
{
    GKAchievement* achievement= [[GKAchievement alloc]
                                 initWithIdentifier: @"writinggamecenterapichapter"];
    achievement.percentComplete= 100;
    achievement.showsCompletionBanner = YES;
    
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler: ^(NSError *error){}];
    
//    [achievement reportAchievementWithCompletionHandler:
//     ^(NSError *error){}];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
