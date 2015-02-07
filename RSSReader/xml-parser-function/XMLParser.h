//
//  XMLParser.h
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "XMLSchema.h"
#import "XMLLog.h"

@protocol XMLParserDelegate <NSObject>
- (void)elementDidParsed:(NSString *)key value:(NSString *)value;
@end

@interface XMLParser : NSObject

@property (nonatomic, assign) id <XMLParserDelegate> delegate;

@property (nonatomic, strong, readonly) NSData* xmlData;
@property (nonatomic, strong, readonly) GDataXMLDocument *xmlDoc;
@property (nonatomic, strong, readonly) GDataXMLElement *rootElement;

- (id)initWithData:(NSData *)data;

- (void)startParser;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
- (void)stopParser;

- (void)postElementDidParsed:(NSString *)key value:(NSString *)value;
- (void)titleOfChannelDidParsed:(NSString *)title;
- (void)linkOfChannelDidParsed:(NSString *)link;
- (void)descriptionOfChannelDidParsed:(NSString *)description;
- (void)pubDateOfChannelDidParsed:(NSString *)date;
@end
