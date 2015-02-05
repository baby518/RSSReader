//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        unsigned long size = [data length];
        NSLog(@"initWithData size : %lu Byte, %lu KB", size, size / 1024);
        _xmlData = data;
        _xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
        _rootElement = [_xmlDoc rootElement];
    }
    return self;
}

- (void)startParser {
    if (_rootElement == nil) {
        LOGE(@"Root Element is not found !!!");
        return;
    } else if (![[_rootElement name] isEqualToString:ROOT_NAME]) {
        LOGE(@"This xml file's ROOT is %@, it seems not a rss file !!!", [_rootElement name]);
        return;
    }
    NSString *version = [[_rootElement attributeForName:ATTRIBUTE_ROOT_VERSION] stringValue];
    LOGD(@"This xml file's VERSION is %@", version);
}

- (void)stopParser {

}

@end
