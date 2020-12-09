//
//  ActionButton.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

@class ActionButton;

@protocol ActionButtonDelegate <NSObject>

- (void)actionButtonWasPressed:(ActionButton *)actionButton;
- (void)actionButtonIsHeld:(ActionButton *)actionButton;
- (void)actionButtonWasReleased:(ActionButton *)actionButton;

@end

@interface ActionButton : SKSpriteNode

@property (weak, nonatomic) id <ActionButtonDelegate> delegate;
@property (assign, nonatomic) BOOL isHeld;

+ (instancetype)buttonWithPrefix:(NSString *)filePrefix
                          radius:(CGFloat)radius;

- (instancetype)initWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius;

- (void)update:(NSTimeInterval)delta;

@end
