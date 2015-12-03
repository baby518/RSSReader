//
//  RSSItemElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSItemElement.h"

@implementation RSSItemElement
- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    [description appendFormat:@"  titleOfElement=%@", self.titleOfElement];
    [description appendFormat:@", linkOfElement=%@", self.linkOfElement];
    [description appendFormat:@", pubDateOfElement=%@", self.pubDateOfElement];
    [description appendFormat:@", descriptionOfElement=%@", self.descriptionOfElement];
    [description appendFormat:@", authorOfItem=%@", self.authorOfItem];
    [description appendFormat:@", authorLinkOfItem=%@", self.authorLinkOfItem];
    [description appendFormat:@", guidOfItem=%@", self.guidOfItem];
    [description appendFormat:@", read=%d", self.read];
    [description appendFormat:@", has content : %d", (self.contentOfItem != nil && ![self.contentOfItem isEqualToString:@""])];
    [description appendString:@">"];
    return description;
}

- (NSString *)authorOfItem {
    if (_authorOfItem == nil || [_authorOfItem isEqual:[NSNull null]]) {
        _authorOfItem = @"";
    }
    return _authorOfItem;
}

- (NSString *)authorLinkOfItem {
    if (_authorLinkOfItem == nil || [_authorLinkOfItem isEqual:[NSNull null]]) {
        _authorLinkOfItem = @"";
    }
    return _authorLinkOfItem;
}

- (NSString *)guidOfItem {
    if (_guidOfItem == nil || [_guidOfItem isEqual:[NSNull null]]) {
        _guidOfItem = @"";
    }
    return _guidOfItem;
}

- (NSString *)contentOfItem {
    if (_contentOfItem == nil || [_contentOfItem isEqual:[NSNull null]]) {
        _contentOfItem = @"";
    }
    return _contentOfItem;
}
@end
