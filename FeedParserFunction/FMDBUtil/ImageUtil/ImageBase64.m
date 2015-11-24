//
// Created by zhangchao on 15/8/12.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "ImageBase64.h"


@implementation ImageBase64 {

}

+ (NSString *)encodeBase64:(NSData *)imageData {
    if (imageData == nil) return nil;
    NSString *base64String;
    if ([imageData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    } else {
        base64String = [imageData base64Encoding];
    }
    return base64String;
}

+ (NSData *)decodeBase64:(NSString *)base64String {
    NSData *imageData;
    if ([base64String hasPrefix:@"data:image/"]) {
        // replace whitespace and \n \r first
        base64String = [base64String stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        base64String = [base64String stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSURL *url = [NSURL URLWithString:base64String];
        imageData = [NSData dataWithContentsOfURL:url];
    } else {
        imageData = [[NSData alloc] initWithBase64EncodedString:base64String
                                                        options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return imageData.length > 0 ? imageData : nil;
}
@end