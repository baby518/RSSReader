//
//  NSRSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "NSRSSParser.h"

#pragma mark NSRSSParser (private)
@interface NSRSSParser ()

@property (nonatomic, strong) NSXMLParser *nsXmlParser;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSMutableString *currentText;
@property (nonatomic, strong) RSSBaseElement *currentChannel;
@property (nonatomic, strong) RSSBaseElement *currentItem;
@property (nonatomic, strong) NSDictionary *currentElementAttributes;

- (void)resetParserData;
@end

@implementation NSRSSParser

#pragma mark RSSParser super
- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    LOGD(@"RSSParser startParser elementStringStyle %ld", elementStringStyle);
    [super startParserWithStyle:elementStringStyle];

    [self resetParserData];

    xmlElementStringStyle = elementStringStyle;
    self.nsXmlParser = [[NSXMLParser alloc] initWithData:self.xmlData];
    self.nsXmlParser.delegate = self;
    [self.nsXmlParser setShouldProcessNamespaces:YES];
    [self.nsXmlParser setShouldReportNamespacePrefixes:YES];
    [self.nsXmlParser setShouldResolveExternalEntities:YES];

    [self.nsXmlParser parse];
}

- (void)stopParser {
    LOGD(@"RSSParser stopParser");
    [self.nsXmlParser abortParsing];

    [super stopParser];
}

#pragma mark NSRSSParser (private)
- (void)resetParserData {
    feedType = FeedTypeUnknown;
    self.currentPath = @"/";
    self.currentText = [[NSMutableString alloc] init];
    self.currentElementAttributes = nil;
}

#pragma mark - NSXMLParseEngine & NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    LOGD(@"parserDidStartDocument");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    LOGD(@"parserDidEndDocument");
    // parsed done.
    LOGD(@"parsed done, postAllElementsDidParsed.");
    [self postAllElementsDidParsed];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    LOGD(@"parseErrorOccurred %@", parseError);
    [self postErrorOccurred:parseError];
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
    if (feedType == FeedTypeUnknown) {
        if ([qName isEqualToString:ROOT_NAME]) {
            feedType = FeedTypeRSS;
        } else {
            LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", qName);
            [self postErrorOccurred:nil];
        }
        return;
    }

    // Entering new feed element
    if (feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_CHANNEL_PATH]) {
        RSSBaseElement *element = [[RSSChannelElement alloc] initWithTitle:@""];
        self.currentChannel = element;
        return;
    }

    if (feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_ITEM_PATH]) {
        RSSBaseElement *element = [[RSSItemElement alloc] initWithTitle:@""];
        self.currentItem = element;
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
        switch (feedType) {
            case FeedTypeRSS: {
                // Process channel
                if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_TITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [RSSParser filterHtmlLabelInString:processedText];
                    }
                    self.currentChannel.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_LINK_PATH]) {
                    self.currentChannel.linkOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_DESCRIPTION_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [RSSParser filterHtmlLabelInString:processedText];
                    }
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

                // Process item
                if ([self.currentPath isEqualToString:ELEMENT_ITEM_TITLE_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).titleOfElement = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_LINK_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).linkOfElement = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_DESCRIPTION_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).descriptionOfElement = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_PUBDATE_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).pubDateStringOfElement = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_DC_CREATOR_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).authorOfItem = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_AUTHOR_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).authorOfItem = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_GUID_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).guidOfItem = processedText;
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
        // post channel's children item
        switch (feedType) {
            case FeedTypeRSS: {
                if ([qName isEqualToString:ELEMENT_ITEM]) {
                    // add items in channel's item array.
                    if (self.currentChannel != nil && [self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        [((RSSChannelElement *) self.currentChannel) addItem:((RSSItemElement *) self.currentItem)];
                    }
                    // post item
                    LOGD(@"postElementDidParsed current item : %@", self.currentItem.description);
                    [self postElementDidParsed:self.currentItem];
                } else if ([qName isEqualToString:ELEMENT_CHANNEL]) {
                    // post channel's info
                    LOGD(@"postElementDidParsed channel's info : %@", self.currentChannel.description);
                    [self postElementDidParsed:self.currentChannel];
                } else if ([qName isEqualToString:ROOT_NAME]) {
                }
            };
            default:
                break;
        }
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

@end
