//
//  BaseFMDBUtil.m
//  
//
//  Created by zhangchao on 15/7/28.
//
//

#import "BaseFMDBUtil.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ImageBase64.h"

@interface BaseFMDBUtil ()
@end

@implementation BaseFMDBUtil

- (instancetype)initWithDBPath:(NSString *)path {
    self = [super init];
    if (self) {
        databaseIsReady = false;
        if (path != nil) {
            NSLog(@"initWithDBPath : %@", path);
            dataBase = [FMDatabase databaseWithPath:path];
            if ([dataBase open]) {
                databaseIsReady = true;
//                [self.dataBase close];
            }
            NSLog(@"initWithDBPath databaseIsReady : %d", databaseIsReady);
        }
    }
    return self;
}

- (void)closeDB {
    [dataBase close];
}

- (NSString *)getFeedTableName {
    return nil;
}

- (BOOL)isTableExist:(NSString *)tableName {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master \n"
                                                       "where type ='table' and name = '%@'", tableName];
    FMResultSet *rs = [dataBase executeQuery:sql];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        NSLog(@"table %@ exist ? %@", tableName, count > 0 ? @"true" : @"false");
        return count > 0;
    }
    return NO;
}

- (BOOL)isTriggerExist:(NSString *)triggerName {
    if (!databaseIsReady) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master \n"
                                                       "where type ='trigger' and name = '%@'", triggerName];
    FMResultSet *rs = [dataBase executeQuery:sql];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        NSLog(@"triggerName %@ exist ? %@", triggerName, count > 0 ? @"true" : @"false");
        return count > 0;
    }
    return NO;
}

- (NSArray *)getAllFeedChannels {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", [self getFeedTableName]];
    return [self getChannelsForQuery:sql];
}

- (NSArray *)getStarredChannels {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE starred='%d'", [self getFeedTableName], 1];
    return [self getChannelsForQuery:sql];
}

- (NSArray *)getAllCategories {
    if (!databaseIsReady) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT category FROM %@", [self getFeedTableName]];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *categoryArray = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *str  = [resultSet stringForColumn:@"category"];
        [categoryArray addObject:str];
    }
    return categoryArray;
}

- (NSArray *)getChannelsInCategory:(NSString *)category {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE category='%@'", [self getFeedTableName], category];
    return [self getChannelsForQuery:sql];
}

- (RSSChannelElement *)getChannelFromURL:(NSString *)url {
    if (!databaseIsReady) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE feedURL = '%@'", [self getFeedTableName], url];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    while ([resultSet next]) {
        NSDictionary *dic = [resultSet resultDictionary];
        RSSChannelElement *element = [self getChannelFromDictionary:dic];
        return element;
    }
    return nil;
}

- (NSArray *)getChannelsForQuery:(NSString *)sql {
    if (!databaseIsReady) {
        return nil;
    }
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *channelArray = [NSMutableArray array];
    while ([resultSet next]) {
        NSDictionary *dic = [resultSet resultDictionary];
        RSSChannelElement *channelElement = [self getChannelFromDictionary:dic];
        if (channelElement != nil) {
            [channelArray addObject:channelElement];
        }
    }
    return channelArray;
}

- (RSSChannelElement *)getChannelFromDictionary:(NSDictionary *)dic {
    NSArray *keys = [dic allKeys];
    RSSChannelElement *element;

    if ([keys containsObject:@"feedURL"]) {
        element = [[RSSChannelElement alloc] initWithURL:[NSURL URLWithString:dic[@"feedURL"]]];
    }
    if (element != nil) {
        for (NSString *key in keys) {
            if ([key isEqualToString:@"feedTitle"]) {
                element.titleOfElement = dic[key];
            } else if ([key isEqualToString:@"websiteURL"]) {
                element.linkOfElement = dic[key];
            } else if ([key isEqualToString:@"description"]) {
                element.descriptionOfElement = dic[key];
            } else if ([key isEqualToString:@"category"]) {
                element.categoryOfElement = dic[key];
            } else if ([key isEqualToString:@"starred"]) {
                NSString *starred = [NSString stringWithFormat:@"%@", dic[key]];
                element.starred = [starred isEqualToString:@"1"];
            } else if ([key isEqualToString:@"favicon"]) {
                // base64 string.
                NSString *base64String = [NSString stringWithFormat:@"%@", dic[key]];
                if (base64String != nil && ![base64String isEqualToString:@"null"]) {
                    element.favIconData = [ImageBase64 decodeBase64:base64String];
                }
            }
        }
    }
    // complete element's property by child's override.
    return element;
}

- (NSData *)getFavIconFromURL:(NSString *)url {
    NSString *sql = [NSString stringWithFormat:@"SELECT favicon FROM %@ WHERE feedURL='%@'", [self getFeedTableName], url];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    while ([resultSet next]) {
        NSString *str = [resultSet stringForColumn:@"favicon"];
        if (str != nil && ![str isEqualToString:@"null"]) {
            return [self decodeBase64:str];
        }
    }
    return nil;
}

// other util functions
- (NSString *)encodeBase64:(NSData *)imageData {
    return [ImageBase64 encodeBase64:imageData];
}

- (NSData *)decodeBase64:(NSString *)base64String {
    return [ImageBase64 decodeBase64:base64String];
}

- (NSInteger)encodeDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSince1970];
    return (NSInteger) interval;
}

- (NSDate *)decodeDate:(NSInteger)dateValue {
    NSDate *result = [NSDate dateWithTimeIntervalSince1970:dateValue];
    return result;
}
@end
