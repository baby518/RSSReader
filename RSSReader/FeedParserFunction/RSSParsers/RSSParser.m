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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(postErrorOccurred:)]) {
            [self.delegate parseErrorOccurred:error];
        }
    });
}

- (void)postElementDidParsed:(RSSBaseElement *)element {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(elementDidParsed:)]) {
            [self.delegate elementDidParsed:element];
        }
    });
}

- (void)postAllElementsDidParsed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(allElementsDidParsed)]) {
            [self.delegate allElementsDidParsed];
        }
    });
}

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString {
    NSAttributedString *attributedString = [[NSAttributedString alloc]
            initWithData:[srcString dataUsingEncoding:NSUnicodeStringEncoding]
                 options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
      documentAttributes:nil
                   error:nil];
    return attributedString.string;
}
@end
