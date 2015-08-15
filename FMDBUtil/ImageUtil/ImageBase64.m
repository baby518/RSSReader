//
// Created by zhangchao on 15/8/12.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "ImageBase64.h"


@implementation ImageBase64 {

}

+ (NSString *)encodeBase64:(NSData *)imageData {
    if (imageData == nil) return nil;
    NSString *base64String = [NSString stringWithFormat:@"data:image/x-icon;base64,%@", [imageData base64Encoding]];
    return base64String;
}

+ (NSData *)decodeBase64:(NSString *)base64String {
    NSURL *url = [NSURL URLWithString:base64String];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return imageData;
}
@end