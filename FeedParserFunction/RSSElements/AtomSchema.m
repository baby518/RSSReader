//
//  AtomSchema.m
//  RSSReader
//
//  Created by zhangchao on 15/5/12.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "AtomSchema.h"

NSString *const ATOM_MIME_TYPE              = @"application/atom+xml";

NSString *const ATOM_ROOT_NAME              = @"feed";
NSString *const ATOM_ROOT_NAME_PATH         = @"/feed";

NSString *const ATOM_FEED_TITLE             = @"title";
NSString *const ATOM_FEED_TITLE_PATH        = @"/feed/title";
NSString *const ATOM_FEED_LINK              = @"link";
NSString *const ATOM_FEED_LINK_PATH         = @"/feed/link";
NSString *const ATOM_FEED_SUBTITLE          = @"subtitle";
NSString *const ATOM_FEED_SUBTITLE_PATH     = @"/feed/subtitle";
NSString *const ATOM_FEED_UPDATED           = @"updated";
NSString *const ATOM_FEED_UPDATED_PATH      = @"/feed/updated";

NSString *const ATOM_ENTRY                  = @"entry";
NSString *const ATOM_ENTRY_PATH             = @"/feed/entry";
NSString *const ATOM_ENTRY_TITLE            = @"title";
NSString *const ATOM_ENTRY_TITLE_PATH       = @"/feed/entry/title";
NSString *const ATOM_ENTRY_LINK             = @"link";
NSString *const ATOM_ENTRY_LINK_PATH        = @"/feed/entry/link";
NSString *const ATOM_ENTRY_UPDATED          = @"updated";
NSString *const ATOM_ENTRY_UPDATED_PATH     = @"/feed/entry/updated";
NSString *const ATOM_ENTRY_AUTHOR           = @"author";
NSString *const ATOM_ENTRY_AUTHOR_PATH      = @"/feed/entry/author";
NSString *const ATOM_ENTRY_AUTHOR_NAME      = @"name";
NSString *const ATOM_ENTRY_AUTHOR_NAME_PATH = @"/feed/entry/author/name";
NSString *const ATOM_ENTRY_AUTHOR_LINK      = @"uri";
NSString *const ATOM_ENTRY_AUTHOR_LINK_PATH = @"/feed/entry/author/uri";
NSString *const ATOM_ENTRY_DC_CREATOR       = @"dc:creator";
NSString *const ATOM_ENTRY_DC_CREATOR_PATH  = @"/feed/entry/dc:creator";
NSString *const ATOM_ENTRY_SUMMARY          = @"summary";
NSString *const ATOM_ENTRY_SUMMARY_PATH     = @"/feed/entry/summary";
NSString *const ATOM_ENTRY_CONTENT          = @"content";
NSString *const ATOM_ENTRY_CONTENT_PATH     = @"/feed/entry/content";
@implementation AtomSchema
+ (NSDate *)convertString2Date:(NSString *)string {
    if (string == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //2015-05-10T10:41:06Z
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss''Z'"];

    NSDate *result = [dateFormatter dateFromString:string];
    return result;
}
@end
