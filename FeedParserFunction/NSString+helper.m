//
// Created by zhangchao on 15/6/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

+ (NSString *)filterHtmlLabelInString:(NSString *)srcString {
//    NSAttributedString *attributedString = [[NSAttributedString alloc]
//            initWithData:[srcString dataUsingEncoding:NSUnicodeStringEncoding]
//                 options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
//      documentAttributes:nil
//                   error:nil];
//    return attributedString.string;

    return [NSString removeHTMLLabel:srcString];
}

+ (NSString *)removeHTMLLabel:(NSString *)html {
    return [NSString removeHTMLLabel:html maxLength:html.length];
}

+ (NSString *)removeHTMLLabel:(NSString *)html maxLength:(NSUInteger)targetLength {
    NSScanner *theScanner;
    NSString *text = nil;

    NSUInteger length = [html length];
    if (length > targetLength) {
        html = [html substringToIndex:MIN(targetLength, length)];
    }

    theScanner = [NSScanner scannerWithString:html];

    while (![theScanner isAtEnd]) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL];

        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];

        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
    }

    return html;
}

+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html {
    return [NSString removeHTMLLabelAndWhitespace:html maxLength:html.length];;
}

+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html maxLength:(NSUInteger)maxLength {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    // delete whitespace and newLine of head and foot;
    NSString *result = [[NSString removeHTMLLabel:html maxLength:maxLength] stringByTrimmingCharactersInSet:whitespace];
    // delete newLine of body.
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    // delete repeat whitespace of body.
    result = [result stringByReplacingOccurrencesOfString:@"   " withString:@" "];
    return result;
}
@end