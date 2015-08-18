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
    return [NSString removeHTMLLabelAndWhitespace:html maxLength:html.length];
}

+ (NSString *)removeHTMLLabelAndWhitespace:(NSString *)html maxLength:(NSUInteger)maxLength {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    // delete whitespace and newLine of head and foot;
    NSString *result = [[NSString removeHTMLLabel:html maxLength:maxLength] stringByTrimmingCharactersInSet:whitespace];

    // delete repeat newLine of body.
    NSRegularExpression *regular;
    regular = [NSRegularExpression regularExpressionWithPattern:@"\n{1,}" options:0 error:nil];
    result = [regular stringByReplacingMatchesInString:result options:0
                                                 range:NSMakeRange(0, result.length) withTemplate:@"\n"];
//    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    // delete repeat whitespace of body.
    regular = [NSRegularExpression regularExpressionWithPattern:@" {1,}" options:0 error:nil];
    result = [regular stringByReplacingMatchesInString:result options:0
                                                 range:NSMakeRange(0, result.length) withTemplate:@" "];
//    result = [result stringByReplacingOccurrencesOfString:@"   " withString:@" "];
    return result;
}

+ (NSString *)removeASCIIFunctionCharacter:(NSString *)source {
    // \x00-\x1F is ASCII Function Character
    // \x09 is 'Tab'
    // \x0A is '\n'
    NSRegularExpression *regular =
            [NSRegularExpression regularExpressionWithPattern:@"[\x00-\x08]|[\x0B-\x1F]" options:0 error:nil];
    source = [regular stringByReplacingMatchesInString:source options:0
                                                 range:NSMakeRange(0, source.length) withTemplate:@""];
    return source;
}
@end