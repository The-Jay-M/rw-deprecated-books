
#import "SKAction+SKTExtras.h"

@implementation SKAction (SKTExtras)

+ (instancetype)skt_afterDelay:(NSTimeInterval)duration perform:(SKAction *)action
{
	return [SKAction sequence:@[[SKAction waitForDuration:duration], action]];
}

+ (instancetype)skt_afterDelay:(NSTimeInterval)duration runBlock:(dispatch_block_t)block
{
	return [self skt_afterDelay:duration perform:[SKAction runBlock:block]];
}

+ (instancetype)skt_removeFromParentAfterDelay:(NSTimeInterval)duration
{
	return [self skt_afterDelay:duration perform:[SKAction removeFromParent]];
}

+ (instancetype)blinkWithDuration:(NSTimeInterval)duration blinks:(NSUInteger)blinks
{
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
        NSTimeInterval progress = elapsedTime / duration;
        NSTimeInterval slice = 1.0f / blinks;
		NSTimeInterval m = fmodf(progress, slice);
		[node setHidden:(m > slice/2) ? NO : YES];
    }];
}

+ (instancetype)showNode:(SKNode *)node
{
    return [SKAction runBlock:^{
        node.hidden = NO;
    }];
}

+ (instancetype)hideNode:(SKNode *)node
{
    return [SKAction runBlock:^{
        node.hidden = YES;
    }];
}


@end
