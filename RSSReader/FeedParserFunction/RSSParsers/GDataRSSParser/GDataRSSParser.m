//
//  GDataRSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "GDataXMLNode.h"
#import "GDataRSSParser.h"

#pragma mark GDataRSSParser (private)
@interface GDataRSSParser ()
// properties used for GDataXML
@property(nonatomic, strong) GDataXMLDocument *gDataXmlDoc;

// methods used for GDataXML
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
@end

@implementation GDataRSSParser

#pragma mark RSSParser super
- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    LOGD(@"GDataRSSParser startParser elementStringStyle %ld", elementStringStyle);
    [super startParserWithStyle:elementStringStyle];

    self.gDataXmlDoc = [[GDataXMLDocument alloc] initWithData:self.xmlData options:0 error:nil];
    [self parserRootElements:self.gDataXmlDoc];
}

- (void)stopParser {
    LOGD(@"GDataRSSParser stopParser");
    [super stopParser];
}

#pragma mark GDataXMLParseEngine
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument {
    GDataXMLElement *gDataRootElement = [xmlDocument rootElement];
    if (gDataRootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        [self postErrorOccurred:nil];
        return;
    } else if (![[gDataRootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [gDataRootElement name]);
        [self postErrorOccurred:nil];
        return;
    }
    feedType = FeedTypeRSS;
    NSString *version = [[gDataRootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
    LOGD(@"This rss file's VERSION is %@", version);
    [self parserChannelElements:gDataRootElement];

    // parsed done.
    LOGD(@"parsed done, postAllElementsDidParsed.");
    [self postAllElementsDidParsed];
}

- (void)parserChannelElements:(GDataXMLElement *)rootElement {
    NSArray *channels = [rootElement elementsForName:ELEMENT_CHANNEL];
    for (GDataXMLElement *channel in channels) {
        if (channel != nil) {
            NSString *channelTitle = [[channel elementsForName:ELEMENT_CHANNEL_TITLE][0] stringValue];
            NSString *channelLink = [[channel elementsForName:ELEMENT_CHANNEL_LINK][0] stringValue];
            NSString *channelDescription = [[channel elementsForName:ELEMENT_CHANNEL_DESCRIPTION][0] stringValue];
            NSString *channelPubDate = [[channel elementsForName:ELEMENT_CHANNEL_PUBDATE][0] stringValue];
            NSString *channelLanguage = [[channel elementsForName:ELEMENT_CHANNEL_LANGUAGE][0] stringValue];
            NSString *channelCopyRight = [[channel elementsForName:ELEMENT_CHANNEL_COPYRIGHT][0] stringValue];

            if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                channelTitle = [RSSParser filterHtmlLabelInString:channelTitle];
                channelDescription = [RSSParser filterHtmlLabelInString:channelDescription];
            }
            RSSChannelElement *channelElement = [[RSSChannelElement alloc] initWithTitle:channelTitle];
            channelElement.linkOfElement = channelLink;
            channelElement.descriptionOfElement = channelDescription;
            channelElement.pubDateStringOfElement = channelPubDate;
            channelElement.languageOfChannel = channelLanguage;
            channelElement.copyrightOfChannel = channelCopyRight;
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
            NSString *itemCreator = [[item elementsForName:ELEMENT_ITEM_DC_CREATOR][0] stringValue];
            NSString *itemAuthor = [[item elementsForName:ELEMENT_ITEM_AUTHOR][0] stringValue];
            NSString *itemGuid = [[item elementsForName:ELEMENT_ITEM_GUID][0] stringValue];

            if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                itemTitle = [RSSParser filterHtmlLabelInString:itemTitle];
                itemDescription = [RSSParser filterHtmlLabelInString:itemDescription];
            }

            RSSItemElement *itemElement = [[RSSItemElement alloc] initWithTitle:itemTitle];
            itemElement.linkOfElement = itemLink;
            itemElement.descriptionOfElement = itemDescription;
            itemElement.pubDateStringOfElement = itemPubDate;
            if (itemCreator != nil) {
                itemElement.authorOfItem = itemCreator;
            } else if (itemAuthor != nil) {
                itemElement.authorOfItem = itemAuthor;
            }
            itemElement.guidOfItem = itemGuid;

            LOGD(@"postElementDidParsed current item : %@", itemElement.description);
            [self postElementDidParsed:itemElement];
        }
    }
}

@end