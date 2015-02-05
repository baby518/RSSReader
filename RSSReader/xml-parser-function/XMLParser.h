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

@interface XMLParser : NSObject

@property (nonatomic, strong, readonly) NSData* xmlData;
@property (nonatomic, strong, readonly) GDataXMLDocument *xmlDoc;
@property (nonatomic, strong, readonly) GDataXMLElement *rootElement;

- (id)initWithData:(NSData *)data;

- (void)startParser;
- (void)parserChannelElements:(GDataXMLElement *)rootElement;
- (void)parserItemElements:(GDataXMLElement *)rootElement;
- (void)stopParser;
@end
