//
//  RSSParser.h
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSAttributedString.h>
#import "RSSSchema.h"
#import "RSSChannelElement.h"
#import "RSSItemElement.h"
#import "LogHelper.h"

@protocol RSSParserDelegate <NSObject>
- (void)parseErrorOccurred:(NSError *)error;
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

@interface RSSParser : NSObject

typedef NS_ENUM(NSInteger, FeedType) {
    FeedTypeUnknown = 0,
    FeedTypeRSS     = 1,
};

@property (nonatomic, assign) FeedType feedType;

@property (nonatomic, assign) id <RSSParserDelegate> delegate;
@property (nonatomic, strong, readonly) NSData* xmlData;
- (id)initWithData:(NSData *)data;
- (void)startParser;
- (void)stopParser;

- (void)postErrorOccurred:(NSError *)error;
- (void)postElementDidParsed:(RSSBaseElement *)element;

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
@end
