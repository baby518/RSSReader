//
//  XMLParser.h
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSAttributedString.h>
#import "GDataXMLNode.h"
#import "RSSSchema.h"
#import "RSSChannelElement.h"
#import "RSSItemElement.h"
#import "XMLLog.h"

typedef NS_ENUM(NSInteger, XMLElementStringStyle) {
    /** return all result ues NSString*/
    XMLElementStringNormal           = 0,
    /** return result filtered HTML label.*/
    XMLElementStringFilterHtmlLabel  = 1,
};
#define XMLElementStringStyleArrays @[@"Normal", @"FilterHtmlLabel"]

typedef NS_ENUM(NSInteger, XMLParseEngine) {
    /** Use GDataXMLParser.*/
    GDataXMLParseEngine  = 0,
    /** Use NSXMLParser*/
    NSXMLParseEngine     = 1,
};
#define XMLParseEngineArrays @[@"GDataXMLParser", @"NSXMLParser"]

@protocol RSSParserDelegate <NSObject>
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

@interface RSSParser : NSObject

@property (nonatomic, assign) id <RSSParserDelegate> delegate;
@property (nonatomic, assign, readonly) XMLElementStringStyle xmlElementStringStyle;
@property (nonatomic, assign, readonly) XMLParseEngine xmlParseEngine;

@property (nonatomic, strong, readonly) NSData* xmlData;
@property (nonatomic, strong, readonly) GDataXMLDocument *xmlDoc;
@property (nonatomic, strong, readonly) GDataXMLElement *rootElement;

- (id)initWithData:(NSData *)data;
- (id)initWithParseEngine:(XMLParseEngine)engine data:(NSData *)data;

- (void)startParser;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
- (void)stopParser;

- (void)postElementDidParsed:(RSSBaseElement *)element;

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
@end
