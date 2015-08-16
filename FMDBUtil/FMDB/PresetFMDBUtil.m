//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "PresetFMDBUtil.h"
#import "ImageBase64.h"

NSString * const PRESET_FEED_TABLE = @"preset_feed_channels";

@implementation PresetFMDBUtil {

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