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
#import "LogHelper.h"

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

@protocol FeedParserDelegate <NSObject>
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

@interface FeedParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) id <FeedParserDelegate> delegate;
@property (nonatomic, assign, readonly) XMLElementStringStyle xmlElementStringStyle;
@property (nonatomic, assign, readonly) XMLParseEngine xmlParseEngine;

@property (nonatomic, strong, readonly) NSData* xmlData;

- (id)initWithData:(NSData *)data;
- (id)initWithData:(NSData *)data parseEngine:(XMLParseEngine)engine;

- (void)startParser;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle;
- (void)stopParser;

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
@end
