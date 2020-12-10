//
//  TagWorker.m
//  TrueTopic
//
//  Created by Marin Todorov on 1/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "TagWorker.h"

@interface TagWorker()
{
    NSLinguisticTagger* tagger;
    NSMutableArray* words;
}
@end

@implementation TagWorker

-(void)get:(int)number ofRealTopicsAtURL:(NSString*)url
completion:(TaggingCompletionBlock)block
{
    //initialize the linguistic tagger
    tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: @[NSLinguisticTagSchemeLexicalClass,NSLinguisticTagSchemeLemma]
                                                    options: kNilOptions];
    
    //setup word and count lists
    words = [NSMutableArray arrayWithCapacity:1000];
    
    //get the text from the web page
    NSString* text = [NSString stringWithContentsOfURL:
                      [NSURL URLWithString: url] encoding:NSUTF8StringEncoding
                                                 error:NULL];
    
    //the list of regexes to cleanup the html content
    NSArray* cleanup = @[
                         @"\\A.*?<body.*?>", //1
                         @"</body>.*?\\Z", //2
                         @"<[^>]+>", //3
                         @"\\W+$"]; //4
    
    //1 run the regexes, get out pure text
    for (NSString* regexString in cleanup) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexString
                                      options:NSRegularExpressionDotMatchesLineSeparators
                                      error:NULL];
        
        text = [regex stringByReplacingMatchesInString:text
                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                 range:NSMakeRange(0, [text length])
                                          withTemplate:@""];
    }
    
    //2 add an artificial end of the text
    text = [text stringByAppendingString:@"\nSTOP."]; 
    
    //3 put the text into the tagger
    [tagger setString: text ];
    
    
    //get the tags out of the text
    [tagger enumerateTagsInRange: NSMakeRange(0, [text length])
                          scheme: NSLinguisticTagSchemeLexicalClass
                         options: NSLinguisticTaggerOmitPunctuation |
     NSLinguisticTaggerOmitWhitespace |
     NSLinguisticTaggerOmitOther |
     NSLinguisticTaggerJoinNames
                      usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop)
     {
         //process tags
         //check for nouns only
         if (tag == NSLinguisticTagNoun) {
             WordCount* word = [WordCount wordWithString:
                                [text substringWithRange: tokenRange]
                                ];
             
             int index = [words indexOfObject: word];
             if (index != NSNotFound) {
                 //existing word - just increase count
                 ((WordCount*)words[index]).count++;
             } else {
                 //new word, add to the list
                 [words addObject: word];
             }
         }

         //check if it's the last sentence in the text
         if (text.length==sentenceRange.location+sentenceRange.length) {
             *stop = YES;
             [words sortUsingSelector:@selector(compare:)];
             NSRange resultRange = NSMakeRange(0,(number < words.count)?
                                               number:words.count );
             block( [words subarrayWithRange: resultRange] );
         }

     }];

}

@end
