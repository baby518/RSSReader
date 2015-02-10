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

typedef NS_ENUM(NSInteger, XMLParseMode) {
    /** return all result ues NSString*/
    XMLParseModeNormal              = 0,
    /** return result filtered HTML label.*/
    XMLParseModeFilterHtmlLabel     = 1,
};
#define XMLParseModeArrays @[@"Normal", @"FilterHtmlLabel"]

@protocol RSSParserDelegate <NSObject>
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

@interface RSSParser : NSObject

@property (nonatomic, assign) id <RSSParserDelegate> delegate;
@property (nonatomic, assign, readonly) XMLParseMode xmlParseMode;

@property (nonatomic, strong, readonly) NSData* xmlData;
@property (nonatomic, strong, readonly) GDataXMLDocument *xmlDoc;
@property (nonatomic, strong, readonly) GDataXMLElement *rootElement;

- (id)initWithData:(NSData *)data;

- (void)startParser;
- (void)startParserWithMode:(XMLParseMode)parseMode;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
- (void)stopParser;

- (void)postElementDidParsed:(RSSBaseElement *)element;

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
@end
