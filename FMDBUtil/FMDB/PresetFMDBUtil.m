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
            }
        }
    }
    return element;
}
@end