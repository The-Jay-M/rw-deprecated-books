//
//  WordCount.m
//  TrueTopic
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "WordCount.h"

@implementation WordCount

+(WordCount*)wordWithString:(NSString*)str
{
    WordCount* word = [[WordCount alloc] init];
    word.word = str;
    word.count = 1;
    return word;
}

//method to compare instances
- (NSComparisonResult)compare:(WordCount *)otherObject {
    return otherObject.count-self.count;
}

//method to check for equal instance values
- (BOOL)isEqual:(id)otherObject
{
    return [self.word compare:((WordCount*)otherObject).word]==NSOrderedSame;
}

-(NSString*)description
{
    return self.word;
}


@end
