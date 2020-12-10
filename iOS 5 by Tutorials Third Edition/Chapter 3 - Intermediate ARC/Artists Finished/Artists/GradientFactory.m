//
//  GradientFactory.m
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

#import "GradientFactory.h"

@implementation GradientFactory

+ (id)sharedInstance
{
    static GradientFactory *sharedInstance;
    static dispatch_once_t done;

    dispatch_once(&done, ^{
        sharedInstance = [[GradientFactory alloc] init];
    });

    return sharedInstance;
}

- (CGGradientRef)newGradientWithColor1:(UIColor *)color1 
                                color2:(UIColor *)color2 
                                color3:(UIColor *)color3 
                              midpoint:(CGFloat)midpoint
{
    NSArray *colors = @[ (id)color1.CGColor, (id)color2.CGColor, (id)color3.CGColor ];

    const CGFloat locations[3] = { 0.0f, midpoint, 1.0f };

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGColorSpaceRelease(colorSpace);

    return gradient;
}

@end
