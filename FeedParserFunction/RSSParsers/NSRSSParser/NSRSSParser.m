//
//  NSRSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "NSRSSParser.h"
#import "AtomSchema.h"
#import "NSString+helper.h"

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

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    LOGD(@"RSSParser startParser elementStringStyle %ld", elementStringStyle);
    [super startParserWithStyle:elementStringStyle];

    [self resetParserData];

    _nsXmlParser = [[NSXMLParser alloc] initWithData:self.xmlData];
    self.nsXmlParser.delegate = self;
    [self.nsXmlParser setShouldProcessNamespaces:YES];
    [self.nsXmlParser setShouldReportNamespacePrefixes:YES];
    [self.nsXmlParser setShouldResolveExternalEntities:YES];

    [self.nsXmlParser parse];
}

- (void)stopParser {
    LOGD(@"NSRSSParser stopParser parsing : %d", parsing);
    if (parsing) {
        [super stopParser];
        [self.nsXmlParser abortParsing];
        [self resetParserData];
    }
}

#pragma mark NSRSSParser (private)
- (void)resetParserData {
    feedType = FeedTypeUnknown;
    self.currentPath = @"/";
    self.currentText = [[NSMutableString alloc] init];
    self.currentElementAttributes = nil;
}

- (void)didParserFinish {
    [super didParserFinish];
    [self resetParserData];
}

#pragma mark - NSXMLParseEngine & NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    LOGD(@"parserDidStartDocument");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    // parsed done.
    [self postAllElementsDidParsed];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    LOGE(@"parseErrorOccurred %@", parseError);
    [self postErrorOccurred:parseError];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    LOGE(@"validationErrorOccurred %@", validationError);
    [self postErrorOccurred:validationError];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // Adjust path
    self.currentPath = [self.currentPath stringByAppendingPathComponent:qName];
    self.currentElementAttributes = attributeDict;
//    LOGD(@"didStartElement currentPath : %@", self.currentPath);
    // Reset
    [self.currentText setString:@""];

    // Determine feed type
    if (feedType == FeedTypeUnknown) {
        if ([qName isEqualToString:ROOT_NAME]) {
            feedType = FeedTypeRSS;
        } else if ([qName isEqualToString:ATOM_ROOT_NAME]) {
            feedType = FeedTypeAtom;
        } else {
            LOGE(@"This xml file's ROOT is %@, it seems not a rss or feed file !!!", qName);
            [self postErrorOccurred:nil];
            return;
        }
        RSSBaseElement *element = [[RSSChannelElement alloc] initWithTitle:@""];
        self.currentChannel = element;
        return;
    }

    // Entering new feed element
    if ((feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_CHANNEL_PATH])
            || (feedType == FeedTypeAtom && [self.currentPath isEqualToString:ATOM_ROOT_NAME_PATH])) {
        return;
    }

    if ((feedType == FeedTypeRSS && [self.currentPath isEqualToString:ELEMENT_ITEM_PATH])
            || (feedType == FeedTypeAtom && [self.currentPath isEqualToString:ATOM_ENTRY_PATH])) {
        RSSBaseElement *element = [[RSSItemElement alloc] initWithTitle:@""];
        self.currentItem = element;
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
//    LOGD(@"didEndElement qualifiedName : %@", qName);
    // Store data
    BOOL processed = NO;

    if (self.currentText != nil) {
        NSString *processedText = [NSString stringWithString:self.currentText];
        // Process
        switch (feedType) {
            case FeedTypeRSS: {
                // Process channel
                if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_TITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentChannel.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_LINK_PATH]) {
                    self.currentChannel.linkOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_CHANNEL_DESCRIPTION_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
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

                // Process image url
                if ([self.currentPath isEqualToString:ELEMENT_IMAGE_URL_PATH]) {
                    self.currentChannel.favIconURL = processedText;
                    processed = YES;
                }

                // Process item
                if ([self.currentPath isEqualToString:ELEMENT_ITEM_TITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentItem.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_LINK_PATH]) {
                    self.currentItem.linkOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_DESCRIPTION_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentItem.descriptionOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_PUBDATE_PATH]) {
                    self.currentItem.pubDateStringOfElement = processedText;
                    processed = YES;
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
                } else if ([self.currentPath isEqualToString:ELEMENT_ITEM_CONTENT_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).contentOfItem = processedText;
                        processed = YES;
                    }
                }
                break;
            }
            case FeedTypeAtom: {
                // Info
                if ([self.currentPath isEqualToString:ATOM_FEED_TITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentChannel.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_FEED_SUBTITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentChannel.descriptionOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_FEED_LINK_PATH]) {
                    self.currentItem.linkOfElement = (self.currentElementAttributes)[@"href"];
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_FEED_UPDATED_PATH]) {
                    self.currentChannel.pubDateStringOfElement = processedText;
                    processed = YES;
                }

                // Item
                if ([self.currentPath isEqualToString:ATOM_ENTRY_TITLE_PATH]) {
                    if (xmlElementStringStyle == XMLElementStringFilterHtmlLabel) {
                        processedText = [NSString filterHtmlLabelInString:processedText];
                    }
                    self.currentItem.titleOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_LINK_PATH]) {
                    self.currentItem.linkOfElement = (self.currentElementAttributes)[@"href"];
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_SUMMARY_PATH]) {
                    self.currentItem.descriptionOfElement = processedText;
                    processed = YES;
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_CONTENT_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).contentOfItem = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_AUTHOR_NAME_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).authorOfItem = processedText;
                        processed = YES;
                    }
                }  else if ([self.currentPath isEqualToString:ATOM_ENTRY_AUTHOR_LINK_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).authorLinkOfItem = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_DC_CREATOR_PATH]) {
                    if ([self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        ((RSSItemElement *) self.currentItem).authorOfItem = processedText;
                        processed = YES;
                    }
                } else if ([self.currentPath isEqualToString:ATOM_ENTRY_UPDATED_PATH]) {
                    self.currentItem.pubDateStringOfElement = processedText;
                    processed = YES;
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
                        // if itemTitle contain filter's key, ignore this item.
                        if ([self needIgnoreItem:self.currentItem.descriptionOfElement]) {
                        } else {
                            [((RSSChannelElement *) self.currentChannel) addItem:((RSSItemElement *) self.currentItem)];
                        }
                    }
                    /* zhangchao Time:2015-04-05,not post items now, just post channel. START ++++*/
//                    // post item
//                    LOGD(@"postElementDidParsed current item : %@", self.currentItem.description);
//                    [self postElementDidParsed:self.currentItem];
                    /* zhangchao Time:2015-04-05,not post items now, just post channel. END ----*/
                } else if ([qName isEqualToString:ELEMENT_CHANNEL]) {
                    // if channel not has pubDate, use first child's pubDate instead.
                    if ([self.currentChannel isKindOfClass:[RSSChannelElement class]]) {
                        if ([self.currentChannel.pubDateStringOfElement isEqualToString:@""]) {
                            for (RSSBaseElement *element in ((RSSChannelElement *) self.currentChannel).itemsOfChannel) {
                                if (element.pubDateOfElement != nil) {
                                    self.currentChannel.pubDateOfElement = self.currentChannel.pubDateOfElement == nil ?
                                            element.pubDateOfElement : [self.currentChannel.pubDateOfElement laterDate:element.pubDateOfElement];
                                }
                            }
                        }
                    }

                    // post channel's info
                    LOGD(@"postElementDidParsed channel's info : %@", self.currentChannel.description);
                    [self postElementDidParsed:self.currentChannel];
                } else if ([qName isEqualToString:ROOT_NAME]) {
                }
            };
            case FeedTypeAtom: {
                if ([qName isEqualToString:ATOM_ENTRY]) {
                    // add items in channel's item array.
                    if (self.currentChannel != nil && [self.currentItem isKindOfClass:[RSSItemElement class]]) {
                        // if itemTitle contain filter's key, ignore this item.
                        if ([self needIgnoreItem:self.currentItem.descriptionOfElement]) {
                        } else {
                            [((RSSChannelElement *) self.currentChannel) addItem:((RSSItemElement *) self.currentItem)];
                        }
                    }
                } else if ([qName isEqualToString:ATOM_ROOT_NAME]) {
                    // if channel not has pubDate, use first child's pubDate instead.
                    if ([self.currentChannel isKindOfClass:[RSSChannelElement class]]) {
                        if ([self.currentChannel.pubDateStringOfElement isEqualToString:@""]) {
                            for (RSSBaseElement *element in ((RSSChannelElement *) self.currentChannel).itemsOfChannel) {
                                if (element.pubDateOfElement != nil) {
                                    self.currentChannel.pubDateOfElement = self.currentChannel.pubDateOfElement == nil ?
                                            element.pubDateOfElement : [self.currentChannel.pubDateOfElement laterDate:element.pubDateOfElement];
                                }
                            }
                        }
                    }
                    // post channel's info
                    LOGD(@"postElementDidParsed atom channel's info : %@", self.currentChannel.description);
                    [self postElementDidParsed:self.currentChannel];
                }
            }
            default:
                break;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//    LOGD(@"foundCharacters : %@", string);

    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *dataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (dataString != nil) {
        [self.currentText appendString:dataString];
    }
}

@end
