//
// Created by zhangchao on 15/6/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (helper)
/** getDateStringSineNow: such as "1 min ago". */
- (NSString *)getDateStringSineNow;
/** convert NSDate to pubDate String. */
- (NSString *)convertToString;
/** convert NSDate to pubDate String, without year. */
- (NSString *)convertToStringWithoutYear;
@end