//
// Created by zhangchao on 15/6/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "NSDate+helper.h"

@implementation NSDate (helper)
- (NSString *)getDateStringSineNow {
    NSTimeInterval timeInterval = [self timeIntervalSinceNow];
    timeInterval = -timeInterval;
    NSTimeInterval temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    } else if ((temp = timeInterval / 60) < 60) {
        result = [NSString stringWithFormat:@"%lu分钟前", (NSInteger) temp];
    } else if ((temp = temp / 60) < 24) {
        result = [NSString stringWithFormat:@"%lu小时前", (NSInteger) temp];
    } else if ((temp = temp / 24) < 30) {
        result = [NSString stringWithFormat:@"%lu天前", (NSInteger) temp];
    } else if ((temp = temp / 30) < 12) {
        result = [NSString stringWithFormat:@"%lu月前", (NSInteger) temp];
    } else {
        temp = temp / 12;
        result = [NSString stringWithFormat:@"%lu年前", (NSInteger) temp];
    }
    return result;
}

- (NSString *)convertToString {
    if (self == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}

- (NSString *)convertToStringWithoutYear {
    if (self == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}
@end