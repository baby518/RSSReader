//
//  RSSChannelElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSChannelElement.h"

@implementation RSSChannelElement

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithTitle:title];
    if (self) {
        _itemsOfChannel = [NSMutableArray array];
        _languageOfChannel = @"";
        _copyrightOfChannel = @"";
    }
    return self;
}

- (void)addItem:(RSSItemElement *)item {
    [_itemsOfChannel addObject:item];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    [description appendString:[super description]];
    [description appendFormat:@", languageOfChannel=%@", self.languageOfChannel];
    [description appendFormat:@", copyrightOfChannel=%@", self.copyrightOfChannel];
    [description appendString:@">"];
    [description appendFormat:@"\n has %ld items", self.itemsOfChannel.count];
    return description;
}
@end
