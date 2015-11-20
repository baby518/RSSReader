//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "UserFMDBUtil.h"
#import "FMDatabaseAdditions.h"

NSString *const USER_FEED_TABLE = @"feed_channels";
NSString *const USER_FEED_CATEGORY_TABLE = @"feed_category";
NSString *const USER_FEED_ITEMS_TABLE = @"feed_items";
static UserFMDBUtil *userDBUtil = nil;

@interface UserFMDBUtil ()
- (instancetype)initWithUserDBPath:(NSString *)path;
- (NSArray *)getAllItemsOfChannel:(NSURL *)feedUrl;
- (RSSItemElement *)getItemsFromDictionary:(NSDictionary *)dic;
@end

@implementation UserFMDBUtil {
}

+ (UserFMDBUtil *)getInstance {
    if (userDBUtil == nil) {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        NSString *appFolder = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
        NSString *userDocFolder = [NSString stringWithFormat:@"%@/%@", docsPath, appFolder];

        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:userDocFolder withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *userFeedPath = [NSString stringWithFormat:@"%@/%@", userDocFolder, @"user_database.sqlite3"];
        if (userFeedPath != nil) {
            userDBUtil = [[UserFMDBUtil alloc] initWithUserDBPath:userFeedPath];
        }
    }
    return userDBUtil;
}

- (instancetype)initWithUserDBPath:(NSString *)path {
    self = [super initWithDBPath:path];
    if (self) {
        // open foreign key support
        [dataBase executeUpdate:@"PRAGMA foreign_keys=ON"];

        // create tables if not exist.
        if (![self isTableExist:[self getFeedCategoryTableName]]) {
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TABLE %@ (category TEXT PRIMARY KEY)",
                    [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }

        if (![self isTableExist:[self getFeedTableName]]) {
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TABLE %@ (feedURL TEXT PRIMARY KEY, websiteURL TEXT, feedTitle TEXT, description TEXT, category TEXT, starred BOOLEAN DEFAULT(0), lastUpdate INTEGER DEFAULT(0), language TEXT, favicon TEXT)",
                    [self getFeedTableName]];
            [dataBase executeUpdate:sql];
        }

        // create feed items table, !has a foreign key!.
        if (![self isTableExist:[self getFeedItemsTableName]]) {
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TABLE %@ (title TEXT, channelURL TEXT, websiteURL TEXT, starred BOOLEAN DEFAULT(0), read BOOLEAN DEFAULT(0), pubDate INTEGER DEFAULT(0), author TEXT, description TEXT, content TEXT, PRIMARY KEY (channelURL, websiteURL), FOREIGN KEY (channelURL) REFERENCES %@ (feedURL) ON DELETE CASCADE ON UPDATE CASCADE)",
                    [self getFeedItemsTableName], [self getFeedTableName]];
            [dataBase executeUpdate:sql];
        }

        // create Triggers
        if (![self isTriggerExist:@"add_feed_category"]) {
            // When insert or update a new channel, add its category into "feed_category"
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TRIGGER add_feed_category AFTER INSERT ON %@ \n"
                            "BEGIN \n"
                            "INSERT or IGNORE INTO %@ (category) VALUES (new.category);\n"
                            "END;",
                    [self getFeedTableName], [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }

        if (![self isTriggerExist:@"remove_feed_category"]) {
            // When delete a channel, remove it's category from "feed_category" if it not exist in "feed_channel" any more.
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TRIGGER remove_feed_category AFTER DELETE ON %@ \n"
                            "WHEN (SELECT count(*) from %@ where category=old.category)<=0 \n"
                            "BEGIN \n"
                            "DELETE FROM %@ WHERE category = old.category;\n"
                            "END;",
                    [self getFeedTableName], [self getFeedTableName], [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }

        if (![self isTriggerExist:@"update_feed_category_add"]) {
            // When update a channel, add its category into "feed_category", as same as add_feed_category
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TRIGGER update_feed_category_add AFTER UPDATE ON %@ \n"
                            "BEGIN \n"
                            "INSERT or IGNORE INTO %@ (category) VALUES (new.category);\n"
                            "END;",
                    [self getFeedTableName], [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }

        if (![self isTriggerExist:@"update_feed_category_remove"]) {
            // When update a channel, remove old category, as same as remove_feed_category
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TRIGGER update_feed_category_remove AFTER UPDATE ON %@ \n"
                            "WHEN (SELECT count(*) from %@ where category=old.category)<=0 \n"
                            "BEGIN \n"
                            "DELETE FROM %@ WHERE category = old.category;\n"
                            "END;",
                    [self getFeedTableName], [self getFeedTableName], [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }
    }
    return self;
}

- (void)closeDB {
    [super closeDB];
    userDBUtil = nil;
}

/** override */
- (NSString *)getFeedTableName {
    return USER_FEED_TABLE;
}

/** override */
- (RSSChannelElement *)getChannelFromDictionary:(NSDictionary *)dic {
    NSArray *keys = [dic allKeys];
    RSSChannelElement *channelElement = [super getChannelFromDictionary:dic];

    if (channelElement != nil) {
        for (NSString *key in keys) {
            if ([key isEqualToString:@"lastUpdate"]) {
                NSInteger intValue = [dic[key] integerValue];
                channelElement.pubDateOfElement = [self decodeDate:intValue];
            } else if ([key isEqualToString:@"language"]) {
                channelElement.languageOfChannel = dic[key];
            }
        }
        // add channel's items.
        NSArray *items = [self getAllItemsOfChannel:channelElement.feedURL];
        for (RSSItemElement *item in items) {
            [channelElement addItem:item];
        }
    }
    return channelElement;
}

/** override */
- (NSArray *)getAllCategories {
    if (!databaseIsReady) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT category FROM %@", [self getFeedCategoryTableName]];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *categoryArray = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *str  = [resultSet stringForColumn:@"category"];
        [categoryArray addObject:str];
    }
    return categoryArray;
}

- (NSString *)getFeedItemsTableName {
    return USER_FEED_ITEMS_TABLE;
}

- (NSString *)getFeedCategoryTableName {
    return USER_FEED_CATEGORY_TABLE;
}

- (BOOL)addChannelElement:(RSSChannelElement *)element {
    return [self updateChannelElement:element];
}

- (BOOL)updateChannelElement:(RSSChannelElement *)element {
    if (!databaseIsReady) {
        return NO;
    }
    if (element == nil) {
        return NO;
    }

    // don't use REPLACE, because replace is remove old --> add new, will trig it's trigger and foreign keys.
    NSInteger lastUpdate = [self encodeDate:element.pubDateOfElement];
    NSString *faviconBase64 = [self encodeBase64:element.favIconData];
    NSString *sql;
    if ([self getChannelFromURL:element.feedURL.absoluteString] == nil) {
        NSLog(@"add element because it is not exist. %@", element.feedURL.absoluteString);
        sql = [NSString stringWithFormat:
                @"INSERT INTO %@ "
                        "(feedURL, websiteURL, feedTitle, description, category, language, starred, favicon, lastUpdate) "
                        "VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%d', '%@', '%ld')",
                [self getFeedTableName], element.feedURL.absoluteString, element.linkOfElement,
                element.titleOfElement, element.descriptionOfElement, element.categoryOfElement,
                element.languageOfChannel, element.starred ? 1 : 0, faviconBase64, lastUpdate];
    } else {
        NSLog(@"update element which already exist. %@", element.feedURL.absoluteString);
        sql = [NSString stringWithFormat:
                @"UPDATE %@ SET "
                        "websiteURL = '%@', "
                        "feedTitle = '%@', "
                        "description = '%@', "
                        "starred = '%d', "
                        "category = '%@', "
                        "language = '%@', "
                        "favicon = '%@', "
                        "lastUpdate = '%ld' "
                        "WHERE feedURL = '%@'",
                [self getFeedTableName], element.linkOfElement, element.titleOfElement,
                element.descriptionOfElement, element.starred ? 1 : 0,
                element.categoryOfElement, element.languageOfChannel,
                faviconBase64, lastUpdate, element.feedURL.absoluteString];
    }

    BOOL result = [dataBase executeUpdate:sql];

    if (result) {
        // update channel's items
        NSArray *items = element.itemsOfChannel;
        for (RSSItemElement *item in items) {
            BOOL itemResult = [self addChannelElementItems:item];
            if (!itemResult) {
                return NO;
            }
        }
    }

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

- (BOOL)deleteChannelFromURL:(NSString *)url {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:
            @"DELETE FROM %@ WHERE feedURL = '%@'", [self getFeedTableName], url];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

#pragma mark - Channel's items
- (BOOL)addChannelElementItems:(RSSItemElement *)item {
    if (!databaseIsReady) {
        return NO;
    }
    if (item == nil) {
        return NO;
    }

    NSInteger pubDate = [self encodeDate:item.pubDateOfElement];

    NSString *sql = [NSString stringWithFormat:
            @"REPLACE INTO %@ "
                    "(title, channelURL, websiteURL, starred, read, pubDate, author, description, content) "
                    "VALUES ('%@', '%@', '%@', '%d', '%d', '%ld', '%@', '%@', '%@')",
            [self getFeedItemsTableName],
            item.titleOfElement, item.feedURL.absoluteString, item.linkOfElement,
            item.starred ? 1 : 0, item.read, pubDate,
            item.authorOfItem, item.descriptionOfElement, item.contentOfItem];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}

- (NSArray *)getAllItemsOfChannel:(NSURL *)feedUrl {
    if (!databaseIsReady) {
        return nil;
    }
    // TODO maybe use more judgment
    NSString *orderString = @" ORDER BY pubDate DESC";
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE channelURL='%@' %@",
                                               [self getFeedItemsTableName], feedUrl.absoluteString, orderString];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *itemsArray = [NSMutableArray array];
    while ([resultSet next]) {
        NSDictionary *dic = [resultSet resultDictionary];
        RSSItemElement *item = [self getItemsFromDictionary:dic];
        if (item != nil) {
            [itemsArray addObject:item];
        }
    }
    return itemsArray;
}

- (RSSItemElement *)getItemsFromDictionary:(NSDictionary *)dic {
    NSArray *keys = [dic allKeys];
    RSSItemElement *item;
    if ([keys containsObject:@"title"]) {
        item = [[RSSItemElement alloc] initWithTitle:dic[@"title"]];
    }

    if (item != nil) {
        for (NSString *key in keys) {
            if ([key isEqualToString:@"websiteURL"]) {
                item.linkOfElement = dic[key];
            } else if ([key isEqualToString:@"description"]) {
                item.descriptionOfElement = dic[key];
            } else if ([key isEqualToString:@"read"]) {
                NSString *read = [NSString stringWithFormat:@"%@", dic[key]];
                item.read = [read isEqualToString:@"1"];
            } else if ([key isEqualToString:@"starred"]) {
                NSString *starred = [NSString stringWithFormat:@"%@", dic[key]];
                item.starred = [starred isEqualToString:@"1"];
            } else if ([key isEqualToString:@"pubDate"]) {
                NSInteger intValue = [dic[key] integerValue];
                item.pubDateOfElement = [self decodeDate:intValue];
            } else if ([key isEqualToString:@"author"]) {
                item.authorOfItem = dic[key];
            } else if ([key isEqualToString:@"content"]) {
                item.contentOfItem = dic[key];
            }
        }
    }
    return item;
}
@end