//
//  ZQRssFeedFetcher.h
//  ZombieQuarterly
//
//  Created by Main Account on 11/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZQRssFeedFetcherDelegate <NSObject>
- (void)fetchFailed:(NSError *)error;
- (void)fetchSuccess:(NSArray *)posts;
@end

@interface ZQRssFeedFetcher : NSObject

- (id)initWithContentURL:(NSURL *)contentURL delegate:(id<ZQRssFeedFetcherDelegate>)delegate;
- (void)fetch;

@end
