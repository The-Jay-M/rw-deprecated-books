//
//  AnimatedView.m
//  Artists
//
//  Created by Matthijs Hollemans.
//  Copyright 2011-2013 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "AnimatedView.h"

@implementation AnimatedView
{
    NSTimer *_timer;
    CFTimeInterval _startTime;
    CFTimeInterval _lastTime;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {

        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];

        _startTime = _lastTime = CACurrentMediaTime();
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc AnimatedView");
}

- (void)stopAnimation
{
    [_timer invalidate], _timer = nil;
}

- (void)handleTimer:(NSTimer*)timer
{
    [self setNeedsDisplay];
}
	
- (void)drawRect:(CGRect)rect
{
    CFTimeInterval now = CACurrentMediaTime();
    CFTimeInterval totalTime = now - _startTime;
    CFTimeInterval deltaTime = now - _lastTime;
    _lastTime = now;

    if (self.block != nil) {
        self.block(UIGraphicsGetCurrentContext(), rect, totalTime, deltaTime);
    }
}

@end
