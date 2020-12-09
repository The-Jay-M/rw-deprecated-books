//
//  AnimationMember.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <Foundation/Foundation.h>

@interface AnimationMember : NSObject

@property (strong, nonatomic) NSMutableArray *textures;
@property (weak, nonatomic)   SKSpriteNode *target;
@property (assign, nonatomic) NSInteger currentIndex;

+ (instancetype)animationWithTextures:(NSMutableArray *)textures
                               target:(SKSpriteNode *)target;

- (instancetype)initWithTextures:(NSMutableArray *)textures
                          target:(SKSpriteNode *)target;

- (void)animateToIndex:(NSInteger)index;

@end
