//
//  MainViewController.m
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

#import "MainViewController.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperation.h"
#import "SoundEffect.h"

@interface MainViewController ()
@end

@implementation MainViewController
{
	NSOperationQueue *_queue;
	NSMutableString *_currentStringValue;
    NSMutableArray *_searchResults;
    SoundEffect *_soundEffect;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Artists";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _soundEffect = nil;

	if ([self isViewLoaded] && self.view.window == nil)
	{
		NSLog(@"forcing my view to unload");
		self.view = nil;
	}

    NSLog(@"tableView %@", self.tableView);
    NSLog(@"searchBar %@", self.searchBar);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.searchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (SoundEffect *)soundEffect
{
	if (_soundEffect == nil) {  // lazy loading
		_soundEffect = [[SoundEffect alloc] initWithSoundNamed:@"Sound.caf"];
	}
	return _soundEffect;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_searchResults == nil) {
		return 0;
	} else if ([_searchResults count] == 0) {
		return 1;
	} else {
		return [_searchResults count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	if ([_searchResults count] == 0) {
		cell.textLabel.text = @"(Nothing found)";
	} else {
		cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
	}
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];

	DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	controller.delegate = self;

	NSString *artistName = _searchResults[indexPath.row];
	controller.artistName = artistName;

	[self.navigationController pushViewController:controller animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_searchResults count] == 0) {
		return nil;
	} else {
		return indexPath;
	}
}

#pragma mark - UISearchBarDelegate

- (NSString *)userAgent
{
	return [NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)",
		[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey],
		[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey],
		@"unknown",
		[[UIDevice currentDevice] systemName],
		[[UIDevice currentDevice] systemVersion],
		[[UIDevice currentDevice] model],
		([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)];
}

- (NSString *)escape:(NSString *)text
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
		NULL,
		(CFStringRef)text,
		NULL,
		(CFStringRef)@"!*'();:@&=+$,/?%#[]",
		CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeGradient];

	NSString *urlString = [NSString stringWithFormat:@"http://musicbrainz.org/ws/2/artist?query=artist:%@&limit=20", [self escape:self.searchBar.text]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

	NSDictionary *headers = [NSDictionary dictionaryWithObject:[self userAgent] forKey:@"User-Agent"];
	[request setAllHTTPHeaderFields:headers];

	AFHTTPRequestOperation *operation = [AFHTTPRequestOperation operationWithRequest:request completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {

		if (response.statusCode == 200 && data != nil) {
			_searchResults = [NSMutableArray arrayWithCapacity:10];

			NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
			[parser setDelegate:self];
			[parser parse];

			[_searchResults sortUsingSelector:@selector(localizedStandardCompare:)];

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.soundEffect play];
				[self.tableView reloadData];
				[SVProgressHUD dismiss];
			});

		} else {  // something went wrong

			dispatch_async(dispatch_get_main_queue(), ^{
				[SVProgressHUD dismissWithError:@"Error"];
			});
		}
	}];

	[_queue addOperation:operation];

	[theSearchBar resignFirstResponder];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"sort-name"]) {
		_currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (_currentStringValue != nil) {
		[_currentStringValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"sort-name"]) {
		[_searchResults addObject:_currentStringValue];
		_currentStringValue = nil;
	}
}

#pragma mark - DetailViewControllerDelegate

- (void)detailViewController:(DetailViewController *)controller 
      didPickButtonWithIndex:(NSInteger)buttonIndex
{
    NSLog(@"Picked button %d", buttonIndex);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
