//
//  GDataRSSParser.m
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "GDataRSSParser.h"
#import "GDataXMLNode.h"

#pragma mark FeedParser (private)

@interface GDataRSSParser ()
// properties used for GDataXML
@property(nonatomic, strong) GDataXMLDocument *gDataXmlDoc;

// methods used for GDataXML
- (void)parserRootElements:(GDataXMLDocument *)xmlDocument;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
@end

@implementation GDataRSSParser

@end