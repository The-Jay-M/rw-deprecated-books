//
//  GameOverScene.m
//  Breakout
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "GameOverScene.h"
#import "HelloWorldScene.h"

@implementation GameOverScene

- (id)init
{
	if ((self = [super init]))
	{
		self.layer = [GameOverLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc
{
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation GameOverLayer

@synthesize label = _label;

- (id)init
{
	if ((self = [super initWithColor:ccc4(255, 255, 255, 255)]))
	{
		CGSize winSize = [[CCDirector sharedDirector] winSize];

		self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
		_label.color = ccc3(0, 0, 0);
		_label.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:_label];

		[self runAction:[CCSequence actions:
			[CCDelayTime actionWithDuration:3],
			[CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
			nil]];
	}	
	return self;
}

- (void)gameOverDone
{
	[[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
}

- (void)dealloc
{
	[_label release];
	_label = nil;
	[super dealloc];
}

@end
