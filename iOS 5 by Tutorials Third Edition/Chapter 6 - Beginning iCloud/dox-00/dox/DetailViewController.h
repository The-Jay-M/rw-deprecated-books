//
//  DetailViewController.h
//  dox
//
//  Created by Cesare Rocchi on 12/4/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
