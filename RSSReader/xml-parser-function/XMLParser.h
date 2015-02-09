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
#import "XMLSchema.h"
#import "XMLLog.h"

typedef NS_ENUM(NSInteger, XMLParseMode) {
    /** return all result ues NSString*/
    XMLParseModeNormal              = 0,
    /** return result use NSAttributedString converted with HTML label.*/
    XMLParseModeUseHtmlLabel        = 1,
    /** return result filtered HTML label.*/
    XMLParseModeFilterHtmlLabel     = 2,
};
#define XMLParseModeArrays @[@"Normal", @"UseHtmlLabel", @"FilterHtmlLabel"]

@protocol XMLParserDelegate <NSObject>
- (void)elementDidParsed:(NSString *)parent key:(NSString *)key value:(NSString *)value;
- (void)elementDidParsed:(NSString *)parent key:(NSString *)key attributedValue:(NSAttributedString *)value;
@end

@interface XMLParser : NSObject

@property (nonatomic, assign) id <XMLParserDelegate> delegate;
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

- (void)postElementDidParsed:(NSString *)parent key:(NSString *)key value:(NSString *)value;
- (void)titleOfChannelDidParsed:(NSString *)title;
- (void)linkOfChannelDidParsed:(NSString *)link;
- (void)descriptionOfChannelDidParsed:(NSString *)description;
- (void)pubDateOfChannelDidParsed:(NSString *)date;
@end
