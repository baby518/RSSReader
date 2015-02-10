//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSParser.h"

@implementation RSSParser

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
            NSString *channelLink = [[channel elementsForName:ELEMENT_CHANNEL_LINK][0] stringValue];
            NSString *channelDescription = [[channel elementsForName:ELEMENT_CHANNEL_DESCRIPTION][0] stringValue];
            NSString *channelPubDate = [[channel elementsForName:ELEMENT_CHANNEL_PUBDATE][0] stringValue];

            if (_xmlParseMode == XMLParseModeFilterHtmlLabel) {
                channelTitle = [RSSParser filterHtmlLabelInString:channelTitle];
                channelDescription = [RSSParser filterHtmlLabelInString:channelDescription];
            }
            RSSChannelElement *channelElement = [[RSSChannelElement alloc] initWithTitle:channelTitle];
            channelElement.linkOfElement = channelLink;
            channelElement.descriptionOfElement = channelDescription;
            channelElement.pubDateStringOfElement = channelPubDate;
//            NSLog(@"%@",channelElement.description);
            [self postElementDidParsed:channelElement];

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

- (void)postElementDidParsed:(RSSBaseElement *)element {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate != nil) {
            [_delegate elementDidParsed:element];
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
