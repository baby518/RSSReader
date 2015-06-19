//
//  AtomSchema.h
//  RSSReader
//
//  Created by zhangchao on 15/5/12.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ATOM_MIME_TYPE;

extern NSString *const ATOM_ROOT_NAME;
extern NSString *const ATOM_ROOT_NAME_PATH;

extern NSString *const ATOM_FEED_TITLE;
extern NSString *const ATOM_FEED_TITLE_PATH;
extern NSString *const ATOM_FEED_LINK;
extern NSString *const ATOM_FEED_LINK_PATH;
extern NSString *const ATOM_FEED_SUBTITLE;
extern NSString *const ATOM_FEED_SUBTITLE_PATH;
extern NSString *const ATOM_FEED_UPDATED;
extern NSString *const ATOM_FEED_UPDATED_PATH;

extern NSString *const ATOM_ENTRY;
extern NSString *const ATOM_ENTRY_PATH;
extern NSString *const ATOM_ENTRY_TITLE;
extern NSString *const ATOM_ENTRY_TITLE_PATH;
extern NSString *const ATOM_ENTRY_LINK;
extern NSString *const ATOM_ENTRY_LINK_PATH;
extern NSString *const ATOM_ENTRY_UPDATED;
extern NSString *const ATOM_ENTRY_UPDATED_PATH;
extern NSString *const ATOM_ENTRY_AUTHOR;
extern NSString *const ATOM_ENTRY_AUTHOR_PATH;
extern NSString *const ATOM_ENTRY_AUTHOR_NAME;
extern NSString *const ATOM_ENTRY_AUTHOR_NAME_PATH;
extern NSString *const ATOM_ENTRY_AUTHOR_LINK;
extern NSString *const ATOM_ENTRY_AUTHOR_LINK_PATH;
extern NSString *const ATOM_ENTRY_DC_CREATOR;
extern NSString *const ATOM_ENTRY_DC_CREATOR_PATH;
extern NSString *const ATOM_ENTRY_SUMMARY;
extern NSString *const ATOM_ENTRY_SUMMARY_PATH;
extern NSString *const ATOM_ENTRY_CONTENT;
extern NSString *const ATOM_ENTRY_CONTENT_PATH;

@interface AtomSchema : NSObject

/** convert pubDate String to NSDate. */
+ (NSDate *)convertString2Date:(NSString *)string;
@end
