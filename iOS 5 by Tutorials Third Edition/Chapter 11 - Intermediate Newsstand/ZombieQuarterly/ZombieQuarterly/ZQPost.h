//
//  ZQPost.h
//  Zombie Quarterly
//
//  Created by Ray Wenderlich on 10/4/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZQPost : NSObject

@property (nonatomic, strong) NSString * header;
@property (nonatomic, strong) NSString * iconUrl;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSDate * date;

@end
