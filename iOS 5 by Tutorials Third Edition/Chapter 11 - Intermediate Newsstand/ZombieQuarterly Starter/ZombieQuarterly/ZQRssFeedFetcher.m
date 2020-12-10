//
//  ZQRssFeedFetcher.m
//  ZombieQuarterly
//
//  Created by Main Account on 11/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ZQRssFeedFetcher.h"
#import "AFNetworking.h"
#import "ZQPost.h"

@interface ZQRssFeedFetcher () <NSXMLParserDelegate>
@end

@implementation ZQRssFeedFetcher {
    NSURL * _contentURL;
    id<ZQRssFeedFetcherDelegate> _delegate;
    NSSet * _itemKeys;
    NSDateFormatter * _dateFormatter;
    
    NSMutableArray * _posts;
    BOOL _fetching;
    ZQPost * _pendingPost;
    NSString * _pendingTag;
    NSMutableString * _pendingValue;
}

- (id)initWithContentURL:(NSURL *)contentURL delegate:(id<ZQRssFeedFetcherDelegate>)delegate {
    if ((self = [super init])) {
        _contentURL = contentURL;
        _delegate = delegate;
        _itemKeys = [[NSSet alloc] initWithObjects:@"title", @"description", @"pubdate", @"category", nil];
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:sss ZZZ"; // Sat, 15 Oct 2011 13:48:00 -0400
    }
    return self;
}

- (void)fetch {

    if (_fetching) return;
    
    _fetching = YES;
    _posts = [NSMutableArray array];
    _pendingPost = nil;
    _pendingTag = nil;
    _pendingValue = nil;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    
    [manager GET:[_contentURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        parser.delegate = self;
        if ([parser parse] == YES) {
            [_delegate fetchSuccess:_posts];
        }
        _fetching = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSString * lowercaseElementName = [elementName lowercaseString];
    
    if ([lowercaseElementName isEqualToString:@"item"]) {
        _pendingPost = [[ZQPost alloc] init];
    }
    
    if ([_itemKeys containsObject:lowercaseElementName]) {
        _pendingTag = lowercaseElementName;
        _pendingValue = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_pendingValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    NSString * lowercaseElementName = [elementName lowercaseString];
    
    if ([lowercaseElementName isEqualToString:@"item"]) {
        // RSS presents most reent first; we reverse this here
        [_posts insertObject:_pendingPost atIndex:0];
    }
    
    if ([lowercaseElementName isEqualToString:_pendingTag]) {
        if ([lowercaseElementName isEqualToString:@"title"]) {
            _pendingPost.header = _pendingValue;
        }
        else if ([lowercaseElementName isEqualToString:@"pubdate"]) {
            _pendingPost.date = [_dateFormatter dateFromString:_pendingValue];
        }
        else if ([lowercaseElementName isEqualToString:@"description"]) {
            
            NSMutableString *workingBody = [NSMutableString stringWithString:_pendingValue];
            [workingBody replaceOccurrencesOfString:@"<p>"
                                         withString:@""
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0, [workingBody length])];
            [workingBody replaceOccurrencesOfString:@"</p>"
                                         withString:@"\n"
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0, [workingBody length])];
            
            _pendingPost.body = workingBody;
            
        }
        else if ([lowercaseElementName isEqualToString:@"category"]) {
            _pendingPost.iconUrl = _pendingValue;
        }
        
        _pendingTag = nil;
        _pendingValue = nil;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    _fetching = NO;
    [_delegate fetchFailed:parseError];
}

@end
