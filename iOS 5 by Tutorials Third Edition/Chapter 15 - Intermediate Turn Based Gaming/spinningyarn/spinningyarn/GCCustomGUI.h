//
//  GCCustomGUI.h
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/7/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "GCTurnBasedMatchHelper.h"

@interface GCCustomGUI : UITableViewController

@property (nonatomic, weak) ViewController * vc;

-(BOOL)isVisible;
-(void)reloadTableView;

@end
