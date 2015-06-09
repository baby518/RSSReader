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
        result = NSLocalizedStringFromTable(@"DateString.Now", @"FeedParser", @"Now");
    } else if ((temp = timeInterval / 60) < 60) {
        NSInteger number = (NSInteger) temp;
        result = [NSString stringWithFormat:@"%lu %@", number, number > 1 ?
                NSLocalizedStringFromTable(@"DateString.MinsAgo", @"FeedParser", @"mins ago") :
                NSLocalizedStringFromTable(@"DateString.MinAgo", @"FeedParser", @"min ago")];
    } else if ((temp = temp / 60) < 24) {
        NSInteger number = (NSInteger) temp;
        result = [NSString stringWithFormat:@"%lu %@", number, number > 1 ?
                NSLocalizedStringFromTable(@"DateString.HoursAgo", @"FeedParser", @"hours ago") :
                NSLocalizedStringFromTable(@"DateString.HourAgo", @"FeedParser", @"hour ago")];
    } else if ((temp = temp / 24) < 30) {
        NSInteger number = (NSInteger) temp;
        result = [NSString stringWithFormat:@"%lu %@", number, number > 1 ?
                NSLocalizedStringFromTable(@"DateString.DaysAgo", @"FeedParser", @"days ago") :
                NSLocalizedStringFromTable(@"DateString.DayAgo", @"FeedParser", @"day ago")];
    } else if ((temp = temp / 30) < 12) {
        NSInteger number = (NSInteger) temp;
        result = [NSString stringWithFormat:@"%lu %@", number, number > 1 ?
                NSLocalizedStringFromTable(@"DateString.MonthsAgo", @"FeedParser", @"months ago") :
                NSLocalizedStringFromTable(@"DateString.MonthAgo", @"FeedParser", @"month ago")];
    } else {
        temp = temp / 12;
        NSInteger number = (NSInteger) temp;
        result = [NSString stringWithFormat:@"%lu %@", number, number > 1 ?
                NSLocalizedStringFromTable(@"DateString.YearsAgo", @"FeedParser", @"years ago") :
                NSLocalizedStringFromTable(@"DateString.YearAgo", @"FeedParser", @"year ago")];
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