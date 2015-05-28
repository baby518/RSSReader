//
//  RSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSParser.h"

#pragma mark RSSParser (private)
@interface RSSParser ()
@end

@implementation RSSParser
- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        LOGD(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);
        _xmlData = data;
    }
    return self;
}

- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    xmlElementStringStyle = elementStringStyle;
}

- (void)stopParser {
}

#pragma mark Post Element Parse Result

- (void)postErrorOccurred:(NSError *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(postErrorOccurred:)]) {
        [self.delegate parseErrorOccurred:error];
    }
}

- (void)postElementDidParsed:(RSSBaseElement *)element {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(elementDidParsed:)]) {
        [self.delegate elementDidParsed:element];
    }
}

- (void)postAllElementsDidParsed {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(allElementsDidParsed)]) {
        [self.delegate allElementsDidParsed];
    }
}

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString {
//    NSAttributedString *attributedString = [[NSAttributedString alloc]
//            initWithData:[srcString dataUsingEncoding:NSUnicodeStringEncoding]
//                 options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
//      documentAttributes:nil
//                   error:nil];
//    return attributedString.string;

    return [RSSParser removeHTMLLabel:srcString];
}

+ (NSString *)removeHTMLLabel:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];

    while (![theScanner isAtEnd]) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL];

        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];

        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
    }

    return html;
}

+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [[RSSParser removeHTMLLabel:html] stringByTrimmingCharactersInSet:whitespace];
}
@end
