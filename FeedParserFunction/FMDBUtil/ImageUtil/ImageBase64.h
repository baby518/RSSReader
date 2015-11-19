//
// Created by zhangchao on 15/8/12.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageBase64 : NSObject

+ (NSString *)encodeBase64:(NSData *)imageData;
+ (NSData *)decodeBase64:(NSString *)base64String;
@end