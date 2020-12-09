//
//  SKTTextureCache.m
//  PompaDroidSK
//
//  Created by Allen Benson G Tan on 10/29/13.
//  Copyright (c) 2013 White Widget Limited. All rights reserved.
//

#import "SKTTextureCache.h"
@import SpriteKit;

@interface SKTTextureCache()

@property (nonatomic, strong) NSMutableDictionary *textureCache;

@end

@implementation SKTTextureCache

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static SKTTextureCache * _sharedInstance;
    dispatch_once(&pred, ^{ _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.textureCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadTexturesFromAtlas:(SKTextureAtlas *)textureAtlas filteringMode:(SKTextureFilteringMode)filteringMode
{
    NSArray *textureNames = [textureAtlas textureNames];
    NSString *textureName;
    for (textureName in textureNames)
    {
        NSString *trimmedTextureName = [textureName stringByDeletingPathExtension];
        
        SKTexture *texture = [textureAtlas textureNamed:trimmedTextureName];
         [texture setFilteringMode:filteringMode];
    }
}

- (void)addTexturesFromAtlas:(SKTextureAtlas *)textureAtlas filteringMode:(SKTextureFilteringMode)filteringMode
{
    NSArray *textureNames = [textureAtlas textureNames];
    NSString *textureName;
    
    NSMutableDictionary *iPhoneSDTextures = [NSMutableDictionary dictionary];
    NSMutableDictionary *iPhoneHDTextures = [NSMutableDictionary dictionary];
    NSMutableDictionary *iPadSDTextures = [NSMutableDictionary dictionary];
    NSMutableDictionary *iPadHDTextures = [NSMutableDictionary dictionary];
    
    NSString *iPhoneHDSuffix = @"@2x";
    NSString *iPadSDSuffix = @"@~ipad";
    NSString *iPadHDSuffix = @"@2x~ipad";
    
    for (textureName in textureNames)
    {
        NSString *trimmedTextureName = [textureName stringByDeletingPathExtension];

        SKTexture *texture = [textureAtlas textureNamed:trimmedTextureName];
        
        if ([trimmedTextureName rangeOfString:iPadHDSuffix].location != NSNotFound)
        {
            NSString *baseTextureName = [trimmedTextureName stringByReplacingOccurrencesOfString:iPadHDSuffix withString:@""];
            [iPadHDTextures setObject:texture forKey:baseTextureName];
        }
        else if ([trimmedTextureName rangeOfString:iPadSDSuffix].location != NSNotFound)
        {
            NSString *baseTextureName = [trimmedTextureName stringByReplacingOccurrencesOfString:iPadSDSuffix withString:@""];
            [iPadSDTextures setObject:texture forKey:baseTextureName];
        }
        else if ([trimmedTextureName rangeOfString:iPhoneHDSuffix].location != NSNotFound)
        {
            NSString *baseTextureName = [trimmedTextureName stringByReplacingOccurrencesOfString:iPhoneHDSuffix withString:@""];
            [iPhoneHDTextures setObject:texture forKey:baseTextureName];
        }
        else
        {
            [iPhoneSDTextures setObject:texture forKey:trimmedTextureName];
        }
        
        [texture setFilteringMode:filteringMode];
    }
    
    [_textureCache addEntriesFromDictionary:iPhoneSDTextures];
    
    if (IS_RETINA())
    {
        [_textureCache addEntriesFromDictionary:iPhoneHDTextures];
    }
    
    if (IS_IPAD())
    {
        if (_enableFallbackSuffixes)
        {
            [_textureCache addEntriesFromDictionary:iPhoneHDTextures];
        }
        [_textureCache addEntriesFromDictionary:iPadSDTextures];
    }
    
    if (IS_IPAD() && IS_RETINA())
    {
        if (_enableFallbackSuffixes)
        {
            [_textureCache addEntriesFromDictionary:iPhoneHDTextures];
            [_textureCache addEntriesFromDictionary:iPadSDTextures];
        }
        [_textureCache addEntriesFromDictionary:iPadHDTextures];
    }
    
}

- (SKTexture *)textureNamed:(NSString *)textureName
{
    return _textureCache[textureName];
}




@end
