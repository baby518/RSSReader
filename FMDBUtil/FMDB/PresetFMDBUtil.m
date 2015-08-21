//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "PresetFMDBUtil.h"

NSString *const PRESET_FEED_TABLE = @"preset_feed_channels";
static PresetFMDBUtil *presetDBUtil = nil;

@interface PresetFMDBUtil ()
- (instancetype)initWithPresetDBPath:(NSString *)path;
@end

@implementation PresetFMDBUtil {
}

+ (PresetFMDBUtil *)getInstance {
    if (presetDBUtil == nil) {
        NSString *presetDBPath = [[NSBundle mainBundle] pathForResource:@"preset_database" ofType:@"sqlite3"];
        presetDBUtil = [[PresetFMDBUtil alloc] initWithPresetDBPath:presetDBPath];
    }
    return presetDBUtil;
}

- (instancetype)initWithPresetDBPath:(NSString *)path {
    self = [super initWithDBPath:path];
    if (self) {
    }
    return self;
}

/** override */
- (NSString *)getFeedTableName {
    return PRESET_FEED_TABLE;
}

/** override */
- (RSSChannelElement *)getChannelFromDictionary:(NSDictionary *)dic {
    NSArray *keys = [dic allKeys];
    RSSChannelElement *element = [super getChannelFromDictionary:dic];

    if (element != nil) {
        for (NSString *key in keys) {
        }
    }
    return element;
}
@end