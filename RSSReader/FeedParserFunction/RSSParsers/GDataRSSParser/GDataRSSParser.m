//
//  GDataRSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "GDataXMLNode.h"
#import "GDataRSSParser.h"
#import "AtomSchema.h"

#pragma mark GDataRSSParser (private)
@interface GDataRSSParser ()
// properties used for GDataXML
@property(nonatomic, strong) GDataXMLDocument *gDataXmlDoc;

// methods used for GDataXML
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument;
// rss type
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement parent:(RSSChannelElement *)parentChannel;
// atom type
- (void)parserFeedElements:(GDataXMLElement *)rootElement;
- (void)parserEntryElements:(GDataXMLElement *)rootElement parent:(RSSChannelElement *)parentChannel;
@end

@implementation GDataRSSParser

#pragma mark RSSParser super

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
    } else if ([[gDataRootElement name] isEqualToString:ROOT_NAME]) {
        feedType = FeedTypeRSS;

        NSString *version = [[gDataRootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
        LOGD(@"This rss file's VERSION is %@", version);
        [self parserChannelElements:gDataRootElement];
    } else if ([[gDataRootElement name] isEqualToString:ATOM_ROOT_NAME]) {
        feedType = FeedTypeAtom;

        [self parserFeedElements:gDataRootElement];
    } else {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file or atom file !!!", [gDataRootElement name]);
        [self postErrorOccurred:nil];
        return;
    }

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

            if (channelTitle == nil) channelTitle = @"";
            if (channelLink == nil) channelLink = @"";
            if (channelDescription == nil) channelDescription = @"";
            if (channelPubDate == nil) channelPubDate = @"";
            if (channelLanguage == nil) channelLanguage = @"";
            if (channelCopyRight == nil) channelCopyRight = @"";

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

            // add items in channel's item array.
            [self parserItemElements:channel parent:channelElement];

            LOGD(@"postElementDidParsed current channel : %@", channelElement.description);
            [self postElementDidParsed:channelElement];
        }
    }
}

- (void)parserItemElements:(GDataXMLElement *)rootElement parent:(RSSChannelElement *)parentChannel{
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
            NSString *content = [[item elementsForName:ELEMENT_ITEM_CONTENT][0] stringValue];

            if (itemTitle == nil) itemTitle = @"";
            if (itemDescription == nil) itemDescription = @"";
            if (itemLink == nil) itemLink = @"";
            if (itemPubDate == nil) itemPubDate = @"";
            if (itemCreator == nil) itemCreator = @"";
            if (itemAuthor == nil) itemAuthor = @"";
            if (itemGuid == nil) itemGuid = @"";
            if (content == nil) content = @"";

            if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                itemTitle = [RSSParser filterHtmlLabelInString:itemTitle];
                itemDescription = [RSSParser filterHtmlLabelInString:itemDescription];
            }

            RSSItemElement *itemElement = [[RSSItemElement alloc] initWithTitle:itemTitle];
            itemElement.linkOfElement = itemLink;
            itemElement.descriptionOfElement = itemDescription;
            itemElement.pubDateStringOfElement = itemPubDate;
            if (![itemCreator isEqualToString:@""]) {
                itemElement.authorOfItem = itemCreator;
            } else if (![itemAuthor isEqualToString:@""]) {
                itemElement.authorOfItem = itemAuthor;
            }
            itemElement.guidOfItem = itemGuid;
            itemElement.contentOfItem = content;

            [parentChannel addItem:itemElement];
            /* zhangchao Time:2015-04-05,not post items now, just post channel. START ++++*/
//            LOGD(@"postElementDidParsed current item : %@", itemElement.description);
//            [self postElementDidParsed:itemElement];
            /* zhangchao Time:2015-04-05,not post items now, just post channel. END ----*/
        }
    }
}

- (void)parserFeedElements:(GDataXMLElement *)rootElement {
    NSString *feedTitle = [[rootElement elementsForName:ATOM_FEED_TITLE][0] stringValue];
    GDataXMLElement *feedLinkElement = [rootElement elementsForName:ATOM_FEED_LINK][0];
    NSString *feedLink = [[feedLinkElement attributeForName:@"href"] stringValue];
    NSString *feedSubtitle = [[rootElement elementsForName:ATOM_FEED_SUBTITLE][0] stringValue];
    NSString *feedUpdated = [[rootElement elementsForName:ATOM_FEED_UPDATED][0] stringValue];

    if (feedTitle == nil) feedTitle = @"";
    if (feedLink == nil) feedLink = @"";
    if (feedSubtitle == nil) feedSubtitle = @"";
    if (feedUpdated == nil) feedUpdated = @"";

    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
        feedTitle = [RSSParser filterHtmlLabelInString:feedTitle];
        feedSubtitle = [RSSParser filterHtmlLabelInString:feedSubtitle];
    }

    // use channel instead feed.....
    RSSChannelElement *channelElement = [[RSSChannelElement alloc] initWithTitle:feedTitle];
    channelElement.linkOfElement = feedLink;
    channelElement.descriptionOfElement = feedSubtitle;
    channelElement.pubDateStringOfElement = feedUpdated;

    // add items in channel's item array.
    [self parserEntryElements:rootElement parent:channelElement];

    LOGD(@"postElementDidParsed current channel : %@", channelElement.description);
    [self postElementDidParsed:channelElement];
}

- (void)parserEntryElements:(GDataXMLElement *)rootElement parent:(RSSChannelElement *)parentChannel{
    NSArray *entries = [rootElement elementsForName:ATOM_ENTRY];
    for (GDataXMLElement *entry in entries) {
        if (entry != nil) {
            NSString *entryTitle = [[entry elementsForName:ATOM_ENTRY_TITLE][0] stringValue];
            NSString *entrySummary = [[entry elementsForName:ATOM_ENTRY_SUMMARY][0] stringValue];
            GDataXMLElement *entryLinkElement = [entry elementsForName:ATOM_ENTRY_LINK][0];
            NSString *entryLink = [[entryLinkElement attributeForName:@"href"] stringValue];
            NSString *entryUpdated = [[entry elementsForName:ATOM_ENTRY_UPDATED][0] stringValue];
            NSString *entryCreator = [[entry elementsForName:ATOM_ENTRY_DC_CREATOR][0] stringValue];
            GDataXMLElement *entryAuthorElement = [entry elementsForName:ATOM_ENTRY_AUTHOR][0];
            NSString *entryAuthor = [[entryAuthorElement elementsForName:ATOM_ENTRY_AUTHOR_NAME][0] stringValue];
            NSString *entryAuthorUri = [[entryAuthorElement elementsForName:ATOM_ENTRY_AUTHOR_LINK][0] stringValue];
            NSString *content = [[entry elementsForName:ATOM_ENTRY_CONTENT][0] stringValue];

            if (entryTitle == nil) entryTitle = @"";
            if (entrySummary == nil) entrySummary = @"";
            if (entryLink == nil) entryLink = @"";
            if (entryUpdated == nil) entryUpdated = @"";
            if (entryCreator == nil) entryCreator = @"";
            if (entryAuthor == nil) entryAuthor = @"";
            if (entryAuthorUri == nil) entryAuthorUri = @"";
            if (content == nil) content = @"";

            if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                entryTitle = [RSSParser filterHtmlLabelInString:entryTitle];
                entrySummary = [RSSParser filterHtmlLabelInString:entrySummary];
            }

            RSSItemElement *itemElement = [[RSSItemElement alloc] initWithTitle:entryTitle];
            itemElement.linkOfElement = entryLink;
            itemElement.descriptionOfElement = entrySummary;
            itemElement.pubDateStringOfElement = entryUpdated;
            if (![entryCreator isEqualToString:@""]) {
                itemElement.authorOfItem = entryCreator;
            } else if (![entryAuthor isEqualToString:@""]) {
                itemElement.authorOfItem = entryAuthor;
            }
            itemElement.authorLinkOfItem = entryAuthorUri;
            itemElement.contentOfItem = content;

            [parentChannel addItem:itemElement];
        }
    }
}

@end