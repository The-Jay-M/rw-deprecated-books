//
//  SKTTextureCache.h
//  PompaDroidSK
//
//  Created by Allen Benson G Tan on 10/29/13.
//  Copyright (c) 2013 White Widget Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SKTTextureCache : NSObject

@property(nonatomic, assign)BOOL enableFallbackSuffixes;

+(instancetype)sharedInstance;
-(void)addTexturesFromAtlas:(SKTextureAtlas *)textureAtlas filteringMode:(SKTextureFilteringMode)filteringMode;
-(SKTexture *)textureNamed:(NSString *)textureName;
-(void)loadTexturesFromAtlas:(SKTextureAtlas *)textureAtlas filteringMode:(SKTextureFilteringMode)filteringMode;


@end
