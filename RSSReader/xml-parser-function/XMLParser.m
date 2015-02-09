//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        NSLog(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);
        _xmlData = data;
        _xmlDoc = [[GDataXMLDocument alloc] initWithData:_xmlData options:0 error:nil];
        _rootElement = [_xmlDoc rootElement];
    }
    return self;
}

- (void)startParser {
    [self startParserWithMode:XMLParseModeNormal];
}

- (void)startParserWithMode:(XMLParseMode)parseMode {
    if (_rootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        return;
    } else if (![[_rootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [_rootElement name]);
        return;
    }
    _xmlParseMode = parseMode;
    NSString *version = [[_rootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
    LOGD(@"This rss file's VERSION is %@", version);
    [self parserChannelElements:_rootElement];
}

- (void)stopParser {

}

- (void)parserChannelElements:(GDataXMLElement *)rootElement {
    NSArray *channels = [rootElement elementsForName:ELEMENT_CHANNEL];
    for (GDataXMLElement *channel in channels) {
        if (channel != nil) {
            NSString *channelTitle = [[channel elementsForName:ELEMENT_CHANNEL_TITLE][0] stringValue];
            [self titleOfChannelDidParsed:channelTitle];
            NSString *channelLink = [[channel elementsForName:ELEMENT_CHANNEL_LINK][0] stringValue];
            [self linkOfChannelDidParsed:channelLink];
            NSString *channelDescription = [[channel elementsForName:ELEMENT_CHANNEL_DESCRIPTION][0] stringValue];
            [self descriptionOfChannelDidParsed:channelDescription];
            NSString *channelPubDate = [[channel elementsForName:ELEMENT_CHANNEL_PUBDATE][0] stringValue];
            [self pubDateOfChannelDidParsed:channelPubDate];

            [self parserItemElements:channel];
        }
    }
}

- (void)parserItemElements:(GDataXMLElement *)rootElement {
    NSArray *items = [rootElement elementsForName:ELEMENT_ITEM];
    for (GDataXMLElement *item in items) {
        if (item != nil) {
            NSString *itemTitle = [[item elementsForName:ELEMENT_ITEM_TITLE][0] stringValue];
            NSString *itemDescription = [[item elementsForName:ELEMENT_ITEM_DESCRIPTION][0] stringValue];
            NSString *itemLink = [[item elementsForName:ELEMENT_ITEM_LINK][0] stringValue];
            NSString *itemPubDate = [[item elementsForName:ELEMENT_ITEM_PUBDATE][0] stringValue];
        }
    }
}

- (void)titleOfChannelDidParsed:(NSString *)title {
    [self postElementDidParsed:ELEMENT_CHANNEL key:ELEMENT_CHANNEL_TITLE value:title];
}

- (void)linkOfChannelDidParsed:(NSString *)link {
    [self postElementDidParsed:ELEMENT_CHANNEL key:ELEMENT_CHANNEL_LINK value:link];
}

- (void)descriptionOfChannelDidParsed:(NSString *)description {
    [self postElementDidParsed:ELEMENT_CHANNEL key:ELEMENT_CHANNEL_DESCRIPTION value:description];
}

- (void)pubDateOfChannelDidParsed:(NSString *)date {
    [self postElementDidParsed:ELEMENT_CHANNEL key:ELEMENT_CHANNEL_PUBDATE value:date];
}

- (void)postElementDidParsed:(NSString *)parent key:(NSString *)key value:(NSString *)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate != nil && value != nil) {
            if (_xmlParseMode == XMLParseModeUseHtmlLabel) {
                NSAttributedString *attributedString = [[NSAttributedString alloc]
                        initWithData:[value dataUsingEncoding:NSUnicodeStringEncoding]
                             options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
                  documentAttributes:nil
                               error:nil];
                [_delegate elementDidParsed:parent key:key attributedValue:attributedString];
                LOGD(@"UseHtmlLabel elementDidParsed parent : %@, key : %@, attributedValue : %@",
                        parent, key, attributedString);
            } else if (_xmlParseMode == XMLParseModeFilterHtmlLabel) {
                NSAttributedString *attributedString = [[NSAttributedString alloc]
                        initWithData:[value dataUsingEncoding:NSUnicodeStringEncoding]
                             options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
                  documentAttributes:nil
                               error:nil];
                [_delegate elementDidParsed:parent key:key value:attributedString.string];
                LOGD(@"FilterHtmlLabel elementDidParsed parent : %@, key : %@, attributedValue : %@",
                        parent, key, attributedString.string);
            } else {
                [_delegate elementDidParsed:parent key:key value:value];
                LOGD(@"elementDidParsed parent : %@, key : %@, value : %@", parent, key, value);
            }
        }
    });
}
@end
