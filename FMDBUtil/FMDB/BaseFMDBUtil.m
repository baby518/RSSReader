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
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = '%@'", tableName];
    FMResultSet *rs = [dataBase executeQuery:sql];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        NSLog(@"table %@ exist ? %@", tableName, count > 0 ? @"true" : @"false");
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
        RSSChannelElement *element = [self getChannelFromDictionary:dic];
        if (element != nil) {
            [channelArray addObject:element];
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
    // complete element's property by child's override.
    return element;
}

@end
