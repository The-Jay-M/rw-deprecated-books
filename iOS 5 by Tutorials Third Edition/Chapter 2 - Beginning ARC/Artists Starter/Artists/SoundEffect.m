//
//  SoundEffect.m
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

#import <AudioToolbox/AudioServices.h>
#import "SoundEffect.h"

@implementation SoundEffect
{
	SystemSoundID _soundID;
}

- (id)initWithSoundNamed:(NSString *)filename
{
	if ((self = [super init])) {

		NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
		if (fileURL != nil) {
			SystemSoundID theSoundID;
			OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &theSoundID);
			if (error == kAudioServicesNoError) {
				_soundID = theSoundID;
			}
		}
	}
	return self;
}

- (void)dealloc
{
	AudioServicesDisposeSystemSoundID(_soundID);
	[super dealloc];
}

- (void)play
{
	AudioServicesPlaySystemSound(_soundID);
}

@end
