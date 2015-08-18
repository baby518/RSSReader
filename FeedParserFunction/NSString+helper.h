//
// Created by zhangchao on 15/6/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)
+ (NSString *)filterHtmlLabelInString:(NSString *)srcString;
+ (NSString *)removeHTMLLabel:(NSString *)html;
+ (NSString *)removeHTMLLabel:(NSString *)html maxLength:(NSUInteger)targetLength;
+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html;
+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html maxLength:(NSUInteger)maxLength;

+ (NSString *)removeASCIIFunctionCharacter:(NSString *)source;
@end