//
// Created by zhangchao on 14/10/26.
// Copyright (c) 2014 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogHelper.h"

extern NSString *const RSS_MIME_TYPE;

extern NSString *const ROOT_NAME;
extern NSString *const ROOT_NAME_PATH;
extern NSString *const ATTRIBUTE_ROOT_VERSION;

extern NSString *const ELEMENT_CHANNEL;
extern NSString *const ELEMENT_CHANNEL_PATH;
extern NSString *const ELEMENT_CHANNEL_TITLE;
extern NSString *const ELEMENT_CHANNEL_TITLE_PATH;
extern NSString *const ELEMENT_CHANNEL_LINK;
extern NSString *const ELEMENT_CHANNEL_LINK_PATH;
extern NSString *const ELEMENT_CHANNEL_DESCRIPTION;
extern NSString *const ELEMENT_CHANNEL_DESCRIPTION_PATH;
extern NSString *const ELEMENT_CHANNEL_PUBDATE;
extern NSString *const ELEMENT_CHANNEL_PUBDATE_PATH;
extern NSString *const ELEMENT_CHANNEL_LANGUAGE;
extern NSString *const ELEMENT_CHANNEL_LANGUAGE_PATH;
extern NSString *const ELEMENT_CHANNEL_COPYRIGHT;
extern NSString *const ELEMENT_CHANNEL_COPYRIGHT_PATH;

extern NSString *const ELEMENT_ITEM;
extern NSString *const ELEMENT_ITEM_PATH;
extern NSString *const ELEMENT_ITEM_TITLE;
extern NSString *const ELEMENT_ITEM_TITLE_PATH;
extern NSString *const ELEMENT_ITEM_LINK;
extern NSString *const ELEMENT_ITEM_LINK_PATH;
extern NSString *const ELEMENT_ITEM_DESCRIPTION;
extern NSString *const ELEMENT_ITEM_DESCRIPTION_PATH;
extern NSString *const ELEMENT_ITEM_PUBDATE;
extern NSString *const ELEMENT_ITEM_PUBDATE_PATH;
extern NSString *const ELEMENT_ITEM_DC_CREATOR;
extern NSString *const ELEMENT_ITEM_DC_CREATOR_PATH;
extern NSString *const ELEMENT_ITEM_AUTHOR;
extern NSString *const ELEMENT_ITEM_AUTHOR_PATH;
extern NSString *const ELEMENT_ITEM_GUID;
extern NSString *const ELEMENT_ITEM_GUID_PATH;

extern int const MAX_ELEMENT_COUNTS;

@interface RSSSchema : NSObject {
}
/** convert pubDate String to NSDate. */
+ (NSDate *)convertString2Date:(NSString *)string;
/** convert NSDate to pubDate String. */
+ (NSString *)convertDate2String:(NSDate *)time;
@end
