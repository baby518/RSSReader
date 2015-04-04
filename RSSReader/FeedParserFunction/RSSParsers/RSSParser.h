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

typedef NS_ENUM(NSInteger, XMLElementStringStyle) {
    /** return all result ues NSString*/
    XMLElementStringNormal           = 0,
    /** return result filtered HTML label.*/
    XMLElementStringFilterHtmlLabel  = 1,
};
#define XMLElementStringStyleArrays @[@"Normal", @"FilterHtmlLabel"]

@protocol RSSParserDelegate <NSObject>
- (void)parseErrorOccurred:(NSError *)error;
- (void)elementDidParsed:(RSSBaseElement *)element;
@end

@interface RSSParser : NSObject {
@protected
    XMLElementStringStyle xmlElementStringStyle;
}

typedef NS_ENUM(NSInteger, FeedType) {
    FeedTypeUnknown = 0,
    FeedTypeRSS     = 1,
};

@property (nonatomic, assign) FeedType feedType;

@property (nonatomic, assign) id <RSSParserDelegate> delegate;
@property (nonatomic, strong, readonly) NSData* xmlData;
- (id)initWithData:(NSData *)data;
- (void)startParser;
- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle;
- (void)stopParser;

- (void)postErrorOccurred:(NSError *)error;
- (void)postElementDidParsed:(RSSBaseElement *)element;

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
@end
