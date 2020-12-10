//
//  WordCount.h
//  TrueTopic
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordCount : NSObject

@property (strong) NSString* word;
@property int count;

+(WordCount*)wordWithString:(NSString*)str;

@end
