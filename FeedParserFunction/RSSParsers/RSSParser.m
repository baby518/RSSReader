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
static NSInteger RETRY_TIME_MAX = 1;
@interface RSSParser ()
@property (nonatomic, assign) NSInteger retryTime;
@end

@implementation RSSParser
- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        LOGD(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);

        _retryTime = 0;
        _xmlData = [self convertData:data removeASCIIFunctionCharacter:NO];
    }
    return self;
}

- (NSData *)convertData:(NSData *)data removeASCIIFunctionCharacter:(BOOL)remove {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string != nil) {
        if ([XMLHelper getXMLEncodingFromHeaderInData:data] == XMLEncodingTypeGB2312) {
            // change encode to utf-8
            string = [string stringByReplacingOccurrencesOfString:@"\"gb2312\""
                                                       withString:@"\"utf-8\""
                                                          options:NSCaseInsensitiveSearch
                                                            range:NSMakeRange(0, MIN(string.length, 40))];
        }
        if (string != nil) {
            if (remove) {
                // remove ascii control character
                LOGE(@"remove ASCII Control from string");
                string = [NSString removeASCIIFunctionCharacter:string];
            }
            return [string dataUsingEncoding:NSUTF8StringEncoding];
        }
        return data;
    }
    return nil;
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
    LOGE(@"postErrorOccurred , %@", error.description);

    if (self.retryTime < RETRY_TIME_MAX) {
        _xmlData = [self convertData:_xmlData removeASCIIFunctionCharacter:YES];
        [self startParserWithStyle:xmlElementStringStyle];
        self.retryTime ++;
    } else {
        _retryTime = 0;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parseErrorOccurred:)]) {
            [self.delegate parseErrorOccurred:error];
        }
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
