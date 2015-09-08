//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "UserFMDBUtil.h"
#import "FMDatabaseAdditions.h"

NSString *const USER_FEED_TABLE = @"feed_channels";
NSString *const USER_FEED_CATEGORY_TABLE = @"feed_category";
static UserFMDBUtil *userDBUtil = nil;

@interface UserFMDBUtil ()
- (instancetype)initWithUserDBPath:(NSString *)path;
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
        // create tables if not exist.
        if (![self isTableExist:[self getFeedCategoryTableName]]) {
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TABLE %@ (category TEXT PRIMARY KEY)",
                    [self getFeedCategoryTableName]];
            [dataBase executeUpdate:sql];
        }

        if (![self isTableExist:[self getFeedTableName]]) {
            NSString *sql = [NSString stringWithFormat:
                    @"CREATE TABLE %@ (feedURL TEXT UNIQUE, feedTitle TEXT, description TEXT, category TEXT, starred BOOLEAN DEFAULT(0), lastUpdate INTEGER DEFAULT(0), favicon TEXT)",
                    [self getFeedTableName]];
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
    RSSChannelElement *element = [super getChannelFromDictionary:dic];

    if (element != nil) {
        for (NSString *key in keys) {
            if ([key isEqualToString:@"lastUpdate"]) {
                NSInteger intValue = [dic[key] integerValue];
                element.pubDateOfElement = [self decodeDate:intValue];
            }
        }
    }
    return element;
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

- (NSString *)getFeedCategoryTableName {
    return USER_FEED_CATEGORY_TABLE;
}

- (BOOL)addChannelElement:(RSSChannelElement *)element {
    if (!databaseIsReady) {
        return NO;
    }
    if (element == nil) {
        return NO;
    }
    NSString *title = element.titleOfElement;
    NSString *description = element.descriptionOfElement;
    BOOL starred = element.starred;
    NSString *category = element.categoryOfElement;
    NSInteger lastUpdate = [self encodeDate:element.pubDateOfElement];
    NSString *faviconBase64 = [self encodeBase64:element.favIconData];

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (feedURL, feedTitle, description, category, starred, favicon, lastUpdate) VALUES ('%@', '%@', '%@', '%@', '%d', '%@', '%ld')", [self getFeedTableName], element.feedURL.absoluteString, title, description, category, starred ? 1 : 0, faviconBase64, lastUpdate];
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

    NSString *title = element.titleOfElement;
    NSString *description = element.descriptionOfElement;
    BOOL starred = element.starred;
    NSString *category = element.categoryOfElement;
    NSInteger lastUpdate = [self encodeDate:element.pubDateOfElement];
    NSString *faviconBase64 = [self encodeBase64:element.favIconData];

    NSString *sql = [NSString stringWithFormat:
            @"UPDATE %@ SET "
                    "feedTitle = '%@', "
                    "description = '%@', "
                    "starred = '%d', "
                    "category = '%@', "
                    "favicon = '%@', "
                    "lastUpdate = '%ld' "
                    "WHERE feedURL = '%@'",
            [self getFeedTableName], title, description, starred ? 1 : 0, category,
            faviconBase64, lastUpdate, element.feedURL.absoluteString];
    BOOL result = [dataBase executeUpdate:sql];
    return result;
}
@end