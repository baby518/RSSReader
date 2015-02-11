//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSParser.h"

#pragma mark RSSParser (private)
@interface RSSParser ()

// properties used for GDataXML
@property (nonatomic, strong, readonly) GDataXMLDocument *gDataXmlDoc;
// properties used for NSXMLParser
@property (nonatomic, strong, readonly) NSXMLParser *nsXmlParser;

// methods used for GDataXML
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;

// methods used for NSXMLParser

// post result
- (void)postElementDidParsed:(RSSBaseElement *)element;

@end

#pragma mark RSSParser
@implementation RSSParser

- (id)initWithData:(NSData *)data {
    return [self initWithParseEngine:GDataXMLParseEngine data:data];
}

- (id)initWithParseEngine:(XMLParseEngine)engine data:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        NSLog(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);
        _xmlParseEngine = engine;
        _xmlData = data;
        if (_xmlParseEngine == NSXMLParseEngine) {
            _nsXmlParser = [[NSXMLParser alloc] initWithData:_xmlData];
            _nsXmlParser.delegate = self;
            [_nsXmlParser setShouldProcessNamespaces:YES];
            [_nsXmlParser setShouldReportNamespacePrefixes:YES];
            [_nsXmlParser setShouldResolveExternalEntities:YES];
        } else if (_xmlParseEngine == GDataXMLParseEngine) {
            _gDataXmlDoc = [[GDataXMLDocument alloc] initWithData:_xmlData options:0 error:nil];
        }
    }
    return self;
}

- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    _xmlElementStringStyle = elementStringStyle;
    if (_xmlParseEngine == NSXMLParseEngine) {
        [_nsXmlParser parse];
    } else if (_xmlParseEngine == GDataXMLParseEngine) {
        [self parserRootElements:_gDataXmlDoc];
    }
}

- (void)stopParser {
}

#pragma mark GDataXMLParseEngine
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument {
    GDataXMLElement *gDataRootElement = [xmlDocument rootElement];
    if (gDataRootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        return;
    } else if (![[gDataRootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [gDataRootElement name]);
        return;
    }
    NSString *version = [[gDataRootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
    LOGD(@"This rss file's VERSION is %@", version);
    [self parserChannelElements:gDataRootElement];
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

            if (_xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                channelTitle = [RSSParser filterHtmlLabelInString:channelTitle];
                channelDescription = [RSSParser filterHtmlLabelInString:channelDescription];
            }
            RSSChannelElement *channelElement = [[RSSChannelElement alloc] initWithTitle:channelTitle];
            channelElement.linkOfElement = channelLink;
            channelElement.descriptionOfElement = channelDescription;
            channelElement.pubDateStringOfElement = channelPubDate;
            channelElement.languageOfChannel = channelLanguage;
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

#pragma mark - NSXMLParseEngine & NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    LOGD(@"parserDidStartDocument");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    LOGD(@"parserDidEndDocument");
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    LOGD(@"parseErrorOccurred %@", parseError);
//    [_delegate onErrorWhenParser:parseError.code];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    LOGD(@"didStartElement elementName : %@", elementName);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    LOGD(@"didEndElement elementName : %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    LOGD(@"foundCharacters : %@", string);
}

#pragma mark PostElementDidParsed
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
