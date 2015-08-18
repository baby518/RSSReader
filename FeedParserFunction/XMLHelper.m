//
// Created by zhangchao on 15/6/5.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "XMLHelper.h"


@implementation XMLHelper {

}

+ (XMLEncodingType)getXMLEncodingFromHeaderInData:(NSData *)data {
    NSData *xmlHeader = [data subdataWithRange:NSMakeRange(0, MIN(data.length, 40))];
    NSString *xmlString = [[NSString alloc] initWithData:xmlHeader encoding:NSUTF8StringEncoding];
    return [self getXMLEncodingFromHeaderInString:xmlString];
}

+ (XMLEncodingType)getXMLEncodingFromHeaderInString:(NSString *)string {
    NSString *xmlString = [string substringWithRange:NSMakeRange(0, MIN(string.length, 40))];
    if ([xmlString rangeOfString:@"\"GB2312\"" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return XMLEncodingTypeGB2312;
    } else if ([xmlString rangeOfString:@"\"UTF-8\"" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return XMLEncodingTypeUTF8;
    }
    return XMLEncodingTypeUnknown;
}
@end