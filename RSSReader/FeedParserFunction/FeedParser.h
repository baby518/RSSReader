//
//  XMLParser.h
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSParser.h"
#import "RSSSchema.h"
#import "RSSChannelElement.h"
#import "RSSItemElement.h"
#import "LogHelper.h"

typedef NS_ENUM(NSInteger, XMLParseEngine) {
    /** Use GDataXMLParser.*/
    GDataXMLParseEngine  = 0,
    /** Use NSXMLParser*/
    NSXMLParseEngine     = 1,
};
#define XMLParseEngineArrays @[@"GDataXMLParser", @"NSXMLParser"]

@protocol FeedParserDelegate <NSObject>
- (void)elementDidParsed:(RSSBaseElement *)element;
- (void)allElementsDidParsed;
@end

/**
* FeedParser has two functions, load data from URL and use RSSParser to parse data.
* */
@interface FeedParser : NSObject <RSSParserDelegate>

@property (nonatomic, weak) id <FeedParserDelegate> delegate;
@property (nonatomic, strong) RSSParser* parser;
@property (nonatomic, assign, readonly) XMLParseEngine xmlParseEngine;

@property (nonatomic, strong, readonly) NSData* xmlData;

- (id)initWithData:(NSData *)data;
/* init with NSURL, must start request before parse.*/
- (id)initWithURL:(NSURL *)feedURL;
/*
* use NSURLConnection sendAsynchronousRequest get data;
* call handler when done it.*/
- (void)startRequestAsync:(void (^)(NSError *error)) handler;
/*
* use NSURLConnection sendSynchronousRequest get data;
* */
- (void)startRequestSync:(NSError **)errorPtr;

- (void)startParser;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle parseEngine:(XMLParseEngine)engine;
- (void)stopParser;
@end
