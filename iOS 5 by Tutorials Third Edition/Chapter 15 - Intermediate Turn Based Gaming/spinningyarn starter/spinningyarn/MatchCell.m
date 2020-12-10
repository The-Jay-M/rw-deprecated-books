//
//  MatchCell.m
//  spinningyarn
//
//  Created by Jake Gundersen on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MatchCell.h"


@implementation MatchCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)loadGame:(id)sender {
    
}

- (IBAction)quitGame:(id)sender {

}



@end
