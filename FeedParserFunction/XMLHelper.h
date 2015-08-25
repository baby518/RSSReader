//
// Created by zhangchao on 15/6/5.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, XMLEncodingType) {
    XMLEncodingTypeUnknown = 0,
    XMLEncodingTypeUTF8    = 1,
    XMLEncodingTypeGB2312  = 2,
    XMLEncodingTypeGBK     = 3,
};
@interface XMLHelper : NSObject
/** get XML Encoding From xml file's Header */
+ (XMLEncodingType)getXMLEncodingFromHeaderInData:(NSData *)data;
+ (XMLEncodingType)getXMLEncodingFromHeaderInString:(NSString *)string;
@end