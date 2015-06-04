//
//  RSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSParser.h"
#import "XMLHelper.h"

#pragma mark RSSParser (private)
@interface RSSParser ()
@end

@implementation RSSParser
- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        LOGD(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);

        if ([XMLHelper getXMLEncodingFromHeaderInData:data] == XMLEncodingTypeGB2312) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (string != nil) {
                string = [string stringByReplacingOccurrencesOfString:@"\"gb2312\""
                                                           withString:@"\"utf-8\""
                                                              options:NSCaseInsensitiveSearch
                                                                range:NSMakeRange(0, 40)];
                _xmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
            }
        } else {
            _xmlData = data;
        }
    }
    return self;
}

- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    xmlElementStringStyle = elementStringStyle;
    parsing = YES;
}

- (void)stopParser {
    parsing = NO;
}

- (BOOL)isParsing {
    return parsing;
}

- (void)didParserFinish {
    LOGD(@"didParserFinish, postAllElementsDidParsed.");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(allElementsDidParsed)]) {
        [self.delegate allElementsDidParsed];
    }
    parsing = NO;
}

#pragma mark Post Element Parse Result

- (void)postErrorOccurred:(NSError *)error {
    [self stopParser];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parseErrorOccurred:)]) {
        [self.delegate parseErrorOccurred:error];
    }
}

- (void)postElementDidParsed:(RSSBaseElement *)element {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(elementDidParsed:)]) {
        [self.delegate elementDidParsed:element];
    }
}

- (void)postAllElementsDidParsed {
    [self didParserFinish];
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
    return [RSSParser removeHTMLLabel:html maxLength:html.length];
}

+ (NSString *)removeHTMLLabel:(NSString *)html maxLength:(NSUInteger)targetLength {
    NSScanner *theScanner;
    NSString *text = nil;

    NSUInteger length = [html length];
    if (length > targetLength) {
        html = [html substringToIndex:MIN(targetLength, length)];
    }

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

+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html maxLength:(NSUInteger)maxLength {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [[RSSParser removeHTMLLabel:html maxLength:maxLength] stringByTrimmingCharactersInSet:whitespace];
}
@end
