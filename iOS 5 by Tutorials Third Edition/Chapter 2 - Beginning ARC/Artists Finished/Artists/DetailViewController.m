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

#import "DetailViewController.h"

@interface DetailViewController ()

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
    NSLog(@"artistName '%@'", self.artistName);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.artistName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)coolAction
{
    [self.delegate detailViewController:self didPickButtonWithIndex:0];
}

- (IBAction)mehAction
{
    [self.delegate detailViewController:self didPickButtonWithIndex:1];
}

@end
