//
//  DetailViewController.h
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

#import <UIKit/UIKit.h>

@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

- (void)detailViewController:(DetailViewController *)controller didPickButtonWithIndex:(NSInteger)buttonIndex;

@end

@interface DetailViewController : UIViewController

@property (nonatomic, weak) id <DetailViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *artistName;

- (IBAction)coolAction;
- (IBAction)mehAction;

@end
