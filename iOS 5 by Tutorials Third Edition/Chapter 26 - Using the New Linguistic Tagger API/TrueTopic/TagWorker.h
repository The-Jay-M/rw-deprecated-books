//
//  TagWorker.h
//  TrueTopic
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordCount.h"

typedef void (^TaggingCompletionBlock)(NSArray* words);

@interface TagWorker : NSObject

-(void)get:(int)number ofRealTopicsAtURL:(NSString*)url completion:(TaggingCompletionBlock)block;

@end

