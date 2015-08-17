//
//  RSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSParser.h"
#import "XMLHelper.h"
#import "NSString+helper.h"

#pragma mark RSSParser (private)
@interface RSSParser ()
@end

@implementation RSSParser
- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        LOGD(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);

        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string != nil) {
            if ([XMLHelper getXMLEncodingFromHeaderInData:data] == XMLEncodingTypeGB2312) {
                // change encode to utf-8
                string = [string stringByReplacingOccurrencesOfString:@"\"gb2312\""
                                                           withString:@"\"utf-8\""
                                                              options:NSCaseInsensitiveSearch
                                                                range:NSMakeRange(0, 40)];
            }
            if (string != nil) {
                // remove ascii control character
                string = [NSString removeASCIIControl:string];
                _xmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                _xmlData = data;
            }
        }
    }
    return self;
}

- (void)setFilterArray:(NSArray *)array {
    // delete same values.
    NSSet *set = [NSSet setWithArray:array];
    _filterKeyArray = [set allObjects];
}

- (BOOL)needIgnoreItem:(NSString *)string {
    // if itemTitle contain filter's key, ignore this item.
    BOOL needReturn = NO;
    for (NSObject *keyString in self.filterKeyArray) {
        if ([keyString isKindOfClass:[NSString class]] && [string containsString:(NSString *) keyString]) {
            needReturn = YES;
        }
        if (needReturn) {
            LOGW(@"This item will be ignored, because has keyString : %@, itemTitle : %@", keyString, string);
            break;
        }
    }
    return needReturn;
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
@end
