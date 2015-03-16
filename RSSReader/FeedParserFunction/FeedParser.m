//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "FeedParser.h"

#pragma mark FeedParser (private)
@interface FeedParser ()

typedef NS_ENUM(NSInteger, FeedType) {
    FeedTypeUnknown = 0,
    FeedTypeRSS     = 1,
};

@property (nonatomic, assign) FeedType feedType;

// properties used for GDataXML
@property (nonatomic, strong) GDataXMLDocument *gDataXmlDoc;
// properties used for NSXMLParser
@property (nonatomic, strong) NSXMLParser *nsXmlParser;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSMutableString *currentText;
@property (nonatomic, strong) RSSBaseElement *currentChannel;
@property (nonatomic, strong) RSSBaseElement *currentChannelItem;
@property (nonatomic, strong) NSDictionary *currentElementAttributes;

- (void)resetParserData;
- (void)parseErrorOccurred;

// methods used for GDataXML
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;

// methods used for NSXMLParser

// post result
- (void)postElementDidParsed:(RSSBaseElement *)element;

@end

#pragma mark FeedParser
@implementation FeedParser

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
            self.nsXmlParser = [[NSXMLParser alloc] initWithData:_xmlData];
            self.nsXmlParser.delegate = self;
            [self.nsXmlParser setShouldProcessNamespaces:YES];
            [self.nsXmlParser setShouldReportNamespacePrefixes:YES];
            [self.nsXmlParser setShouldResolveExternalEntities:YES];
        } else if (_xmlParseEngine == GDataXMLParseEngine) {
            self.gDataXmlDoc = [[GDataXMLDocument alloc] initWithData:_xmlData options:0 error:nil];
        }
    }
    return self;
}

- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _xmlElementStringStyle = elementStringStyle;
        [self resetParserData];
        if (_xmlParseEngine == NSXMLParseEngine) {
            [self.nsXmlParser parse];
        } else if (_xmlParseEngine == GDataXMLParseEngine) {
            [self parserRootElements:self.gDataXmlDoc];
        }
    });
}

- (void)stopParser {
    if (_xmlParseEngine == NSXMLParseEngine) {
        [self.nsXmlParser abortParsing];
    }
}

- (void)resetParserData {
    self.feedType = FeedTypeUnknown;
    if (_xmlParseEngine == NSXMLParseEngine) {
        self.currentPath = @"/";
        self.currentText = [[NSMutableString alloc] init];
        self.currentElementAttributes = nil;
    }
}

- (void)parseErrorOccurred {
    [self resetParserData];
    [self stopParser];
}

#pragma mark GDataXMLParseEngine
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument {
    GDataXMLElement *gDataRootElement = [xmlDocument rootElement];
    if (gDataRootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        [self parseErrorOccurred];
        return;
    } else if (![[gDataRootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [gDataRootElement name]);
        [self parseErrorOccurred];
        return;
    }
    self.feedType = FeedTypeRSS;
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
            NSString *channelCopyRight = [[channel elementsForName:ELEMENT_CHANNEL_COPYRIGHT][0] stringValue];

            if (_xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                channelTitle = [FeedParser filterHtmlLabelInString:channelTitle];
                channelDescription = [FeedParser filterHtmlLabelInString:channelDescription];
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
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // Adjust path
    self.currentPath = [self.currentPath stringByAppendingPathComponent:qName];
    self.currentElementAttributes = attributeDict;
    LOGD(@"didStartElement currentPath : %@", self.currentPath);
    // Reset
    [self.currentText setString:@""];

    // Determine feed type
    if (self.feedType == FeedTypeUnknown) {
        if ([qName isEqualToString:ROOT_NAME]) {
            self.feedType = FeedTypeRSS;
        } else {
            LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", qName);
            [self parseErrorOccurred];
        }
        return;
    }

    // Entering new feed element
    if (self.feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_CHANNEL_PATH]) {
        RSSBaseElement *element = [[RSSChannelElement alloc] initWithTitle:@""];
        self.currentChannel = element;
        return;
    }

    if (self.feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_ITEM_PATH]) {
        RSSBaseElement *element = [[RSSItemElement alloc] initWithTitle:@""];
        self.currentChannelItem = element;
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    LOGD(@"didEndElement qualifiedName : %@", qName);
    // Store data
    BOOL processed = NO;

    if (![self.currentText isEqualToString:@""]) {
        NSString *processedText = [NSString stringWithString:self.currentText];
        // Process
        switch (self.feedType) {
            case FeedTypeRSS: {
                if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_TITLE_PATH]) {
                    self.currentChannel.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_LINK_PATH]) {
                    self.currentChannel.linkOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_DESCRIPTION_PATH]) {
                    self.currentChannel.descriptionOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_PUBDATE_PATH]) {
                    self.currentChannel.pubDateStringOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_LANGUAGE_PATH]) {
                    if ([self.currentChannel isKindOfClass:[RSSChannelElement class]]) {
                        ((RSSChannelElement *) self.currentChannel).languageOfChannel = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_COPYRIGHT_PATH]) {
                    if ([self.currentChannel isKindOfClass:[RSSChannelElement class]]) {
                        ((RSSChannelElement *) self.currentChannel).copyrightOfChannel = processedText;
                        processed = YES;
                    }
                }
                break;
            }
            default:
                break;
        }
    }

    // Adjust path
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];

    if (!processed) {
        if (self.feedType == FeedTypeRSS && [qName isEqualToString:ROOT_NAME]) {
            // post channel's info
            LOGD(@"postElementDidParsed channel's info : %@", self.currentChannel.description);
            [self postElementDidParsed:self.currentChannel];
        }
        // post channel's children item
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    LOGD(@"foundCharacters : %@", string);

    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *dataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (dataString != nil) {
        [self.currentText appendString:dataString];
    }
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
