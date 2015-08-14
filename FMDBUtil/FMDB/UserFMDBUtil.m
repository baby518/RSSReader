//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "UserFMDBUtil.h"
#import "FMDatabaseAdditions.h"
#import "ImageBase64.h"

NSString * const USER_FEED_TABLE = @"feed_channels";

@implementation UserFMDBUtil {

}

- (instancetype)initWithDBPath:(NSString *)path {
    self = [super initWithDBPath:path];
    if (self) {
        // create tables if not exist.
        if (![self isTableExist:[self getFeedTableName]]) {
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (feedTitle TEXT, feedURL TEXT UNIQUE, category TEXT, starred BOOLEAN, favicon TEXT, lastUpdate INTEGER)", [self getFeedTableName]];
            [dataBase executeUpdate:sql];
        }
    }
    return self;
}

/** override */
- (NSString *)getFeedTableName {
    return USER_FEED_TABLE;
}

/** override */
- (RSSChannelElement *)getChannelFromDictionary:(NSDictionary *)dic {
    NSArray *keys = [dic allKeys];
    RSSChannelElement *element;

    if ([keys containsObject:@"feedURL"]) {
        element = [[RSSChannelElement alloc] initWithURL:[NSURL URLWithString:dic[@"feedURL"]]];
    }
    if (element != nil) {
        for (NSString *key in keys) {
//            NSLog(@"query channels key : %@", key);
//            NSLog(@"query channels value : %@", dic[key]);
            if ([key isEqualToString:@"feedTitle"]) {
                element.titleOfElement = dic[key];
            } else if ([key isEqualToString:@"category"]) {
                element.categoryOfElement = dic[key];
            } else if ([key isEqualToString:@"starred"]) {
                NSString *starred = [NSString stringWithFormat:@"%@", dic[key]];
                element.starred = [starred isEqualToString:@"1"];
            } else if ([key isEqualToString:@"favicon"]) {
                // base64 string.
                NSString *base64String = [NSString stringWithFormat:@"%@", dic[key]];
                element.favIconData = [ImageBase64 decodeBase64:base64String];
            } else if ([key isEqualToString:@"lastUpdate"]) {
                // TODO need convert
            }
        }
    }
    return element;
}

- (BOOL)addChannelElement:(RSSChannelElement *)element {
    if (!databaseIsReady) {
        return NO;
    }
    if (element == nil) {
        return NO;
    }
    NSString *name = element.titleOfElement;
    BOOL starred = element.starred;
    NSString *category = element.categoryOfElement;
    // TODO convert lastUpdate
    NSInteger lastUpdate = 0;//element.pubDateOfElement;
    NSString *faviconBase64 = [ImageBase64 encodeBase64:element.favIconData];

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (feedTitle, feedURL, category, starred, favicon, lastUpdate) VALUES ('%@', '%@', '%@', '%d', '%@', '%ld')", [self getFeedTableName], name, element.feedURL.absoluteString, category, starred ? 1 : 0, faviconBase64, lastUpdate];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

- (BOOL)deleteChannelFromURL:(NSString *)url {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:
            @"DELETE FROM %@ WHERE feedURL = '%@'", [self getFeedTableName], url];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

- (BOOL)updateChannelCategoryFromURL:(NSString *)url to:(NSString *)category {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET category = '%@' WHERE feedURL = '%@'", [self getFeedTableName], category, url];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

- (BOOL)updateChannelStarredFromURL:(NSString *)url to:(BOOL)starred {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET starred = '%d' WHERE feedURL = '%@'", [self getFeedTableName], starred ? 1 : 0, url];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

- (BOOL)updateChannelElement:(RSSChannelElement *)element {
    if (!databaseIsReady) {
        return NO;
    }
    if (element == nil) {
        return NO;
    }

    RSSChannelElement *channelElement = [self getChannelFromURL:element.feedURL.absoluteString];
    if (channelElement == nil) {
        NSLog(@"add element because it is not exist. %@", element.feedURL.absoluteString);
        return [self addChannelElement:element];
    }

    NSString *name = element.titleOfElement;
    BOOL starred = element.starred;
    NSString *category = element.categoryOfElement;
    // TODO convert lastUpdate
    NSInteger lastUpdate = 0;//element.pubDateOfElement;
    NSString *faviconBase64 = [ImageBase64 encodeBase64:element.favIconData];

    NSString *sql = [NSString stringWithFormat:
            @"UPDATE %@ SET "
                    "feedTitle = '%@', "
                    "starred = '%d', "
                    "category = '%@', "
                    "favicon = '%@', "
                    "lastUpdate = '%ld' "
                    "WHERE feedURL = '%@'",
                    [self getFeedTableName], name, starred ? 1 : 0, category,
                    faviconBase64, lastUpdate, element.feedURL.absoluteString];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}
@end