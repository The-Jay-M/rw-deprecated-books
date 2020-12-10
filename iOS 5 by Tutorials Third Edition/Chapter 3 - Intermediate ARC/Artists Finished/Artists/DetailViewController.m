//
//  DetailViewController.m
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
#import "DetailViewController.h"
#import "AnimatedView.h"
#import "GradientFactory.h"

@interface DetailViewController ()
@property (nonatomic, weak) IBOutlet AnimatedView *animatedView;
@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc DetailViewController");
    [self.animatedView stopAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.artistName;

    UIFont *font = [UIFont boldSystemFontOfSize:24.0f];
    CGSize textSize = [self.artistName sizeWithFont:font];

    float components[9];
    NSUInteger length = [self.artistName length];
    NSString* lowercase = [self.artistName lowercaseString];

    for (int t = 0; t < 9; ++t) {
        unichar c = [lowercase characterAtIndex:t % length];
        components[t] = ((c * (10 - t)) & 0xFF) / 255.0f;
    }

    UIColor *color1 = [UIColor colorWithRed:components[0] green:components[3] blue:components[6] alpha:1.0f];
    UIColor *color2 = [UIColor colorWithRed:components[1] green:components[4] blue:components[7] alpha:1.0f];
    UIColor *color3 = [UIColor colorWithRed:components[2] green:components[5] blue:components[8] alpha:1.0f];

    __weak DetailViewController *weakSelf = self;

    self.animatedView.block = ^(CGContextRef context, CGRect rect, CFTimeInterval totalTime, CFTimeInterval deltaTime) {

        DetailViewController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGPoint startPoint = CGPointMake(0.0f, 0.0f);
            CGPoint endPoint = CGPointMake(0.0f, rect.size.height);
            CGFloat midpoint = 0.5f + (sinf(totalTime))/2.0f;

            CGGradientRef gradient = [[GradientFactory sharedInstance] newGradientWithColor1:color1 color2:color2 color3:color3 midpoint:midpoint];

            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

            CGGradientRelease(gradient);

            CGPoint textPoint = CGPointMake((rect.size.width - textSize.width)/2.0f, (rect.size.height - textSize.height)/2.0f);

            [strongSelf.artistName drawAtPoint:textPoint withFont:font];
        }
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)coolAction
{
    UIGraphicsBeginImageContextWithOptions(self.animatedView.bounds.size, YES, 0.0f);
    [self.animatedView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *data = UIImagePNGRepresentation(image);
    if (data != nil) {
        NSString *filename = [[self documentsDirectory] stringByAppendingPathComponent:@"Cool.png"];

        NSError *error;
        if (![data writeToFile:filename options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error: %@", error);
        }
    }

    [self.delegate detailViewController:self didPickButtonWithIndex:0];
}

- (IBAction)mehAction
{
    [self.delegate detailViewController:self didPickButtonWithIndex:1];
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

@end
