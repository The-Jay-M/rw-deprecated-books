//
// AppDelegate.m
// Breakout
//
// Created by Matthijs Hollemans.
// Copyright 2011-2012 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "AppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
		[CCDirector setDirectorType:kCCDirectorTypeDefault];

	CCDirector *director = [CCDirector sharedDirector];

	_rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	_rootViewController.wantsFullScreenLayout = YES;

	EAGLView *glView = [EAGLView viewWithFrame:[self.window bounds]
		pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
		depthFormat:0];						// GL_DEPTH_COMPONENT16_OES

	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	[director setOpenGLView:glView];
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];

	[_rootViewController setView:glView];
	self.window.rootViewController = _rootViewController;
	[self.window makeKeyAndVisible];

	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	[director runWithScene:[HelloWorld scene]];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
}

@end
