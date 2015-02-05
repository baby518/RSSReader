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
        _xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
        _rootElement = [_xmlDoc rootElement];
    }
    return self;
}

- (void)startParser {
    if (_rootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        return;
    } else if (![[_rootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [_rootElement name]);
        return;
    }
    NSString *version = [[_rootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
    LOGD(@"This xml file's VERSION is %@", version);
    [self parserChannelElements:_rootElement];
}

- (void)stopParser {

}

- (void)parserChannelElements:(GDataXMLElement *)rootElement {
    NSArray *channels = [rootElement elementsForName:ELEMENT_CHANNEL];
    for (GDataXMLElement *channel in channels) {
        if (channel != nil) {
            NSString *channelTitle = [[channel elementsForName:ELEMENT_CHANNEL_TITLE][0] stringValue];
            LOGD(@"This channel's title is %@", channelTitle);
            NSString *channelDescription = [[channel elementsForName:ELEMENT_CHANNEL_DESCRIPTION][0] stringValue];
            LOGD(@"This channel's description is %@", channelDescription);
            NSString *channelLink = [[channel elementsForName:ELEMENT_CHANNEL_LINK][0] stringValue];
            LOGD(@"This channel's link is %@", channelLink);

            [self parserItemElements:channel];
        }
    }
}

- (void)parserItemElements:(GDataXMLElement *)rootElement {
    NSArray *items = [rootElement elementsForName:ELEMENT_ITEM];
    for (GDataXMLElement *item in items) {
        if (item != nil) {
            NSString *itemTitle = [[item elementsForName:ELEMENT_ITEM_TITLE][0] stringValue];
            LOGD(@"This item's title is %@", itemTitle);
            NSString *itemDescription = [[item elementsForName:ELEMENT_ITEM_DESCRIPTION][0] stringValue];
            LOGD(@"This item's description is %@", itemDescription);
            NSString *itemLink = [[item elementsForName:ELEMENT_ITEM_LINK][0] stringValue];
            LOGD(@"This item's link is %@", itemLink);
            NSString *itemPubDate = [[item elementsForName:ELEMENT_ITEM_PUBDATE][0] stringValue];
            LOGD(@"This item's pubDate is %@", itemPubDate);
        }
    }

}
@end
