//
//  ZQViewController.m
//  ZombieQuarterly
//
//  Created by Main Account on 11/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ZQViewController.h"
#import "ZQRssFeedFetcher.h"
#import "ZQPost.h"
@import NewsstandKit;

@interface ZQViewController () <ZQRssFeedFetcherDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@end

@implementation ZQViewController {
    ZQRssFeedFetcher * _fetcher;
    NSDateFormatter * _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"MMMM d, yyyy";

    NSURL * contentURL = [NSURL URLWithString:@"http://zombiequarterly.tumblr.com/rss"];
    _fetcher = [[ZQRssFeedFetcher alloc] initWithContentURL:contentURL delegate:self];
    [_fetcher fetch];
    
    self.titleLabel.text = @"Loading...";
    self.subtitleLabel.text = @"";
    self.bodyTextView.text = @"";
}

#pragma mark ZQRssFeedFetcherDelegate

- (void)fetchFailed:(NSError *)error {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error fetching RSS feed" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)fetchSuccess:(NSArray *)posts {
    
    ZQPost * post;
    NKLibrary * library = [NKLibrary sharedLibrary];
    if (library.issues.count > 0) {

        // Get most recent issue
        post = posts[library.issues.count - 1];
        NKIssue * currentIssue = [library 
          issueWithName:post.header];
        
        // Set issue as being read
        if (currentIssue) {
            [library setCurrentlyReadingIssue:currentIssue];
        }
        
        // Update icon
        NSURL * imageURL = [NSURL URLWithString:post.iconUrl];
        UIImage * currentIcon = [UIImage imageWithData:[NSData 
          dataWithContentsOfURL:imageURL]];
        [[UIApplication sharedApplication] 
          setNewsstandIconImage:currentIcon];

        // Add +1 to badge
        NSInteger unreadCount = [[UIApplication sharedApplication] 
          applicationIconBadgeNumber];
        [[UIApplication sharedApplication] 
          setApplicationIconBadgeNumber:unreadCount + 1];

    } else {
        post = posts[0];
    }
    
    self.titleLabel.text = post.header;
    self.subtitleLabel.text = [_dateFormatter   
      stringFromDate:post.date];
    self.bodyTextView.text = post.body;
    
}

@end
