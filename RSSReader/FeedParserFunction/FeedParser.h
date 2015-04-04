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
- (void)urlAsyncDidLoad:(NSError *)error;
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

/**
* FeedParser has two functions, load data from URL and use RSSParser to parse data.
* */
@interface FeedParser : NSObject <RSSParserDelegate>

@property (nonatomic, assign) id <FeedParserDelegate> delegate;
@property (nonatomic, strong) RSSParser* parser;
@property (nonatomic, assign, readonly) XMLParseEngine xmlParseEngine;

@property (nonatomic, strong, readonly) NSData* xmlData;

- (id)initWithData:(NSData *)data;
/*
* init with NSURL, use NSURLConnection sendAsynchronousRequest get data;
* call urlAsyncDidLoad when done it.*/
- (id)initWithURLAsync:(NSURL *)feedURL;
/*
* init with NSURL, use NSURLConnection sendSynchronousRequest get data;
* */
- (id)initWithURLSync:(NSURL *)feedURL error:(NSError **)errorPtr;

- (void)startParser;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle parseEngine:(XMLParseEngine)engine;
- (void)stopParser;
@end
