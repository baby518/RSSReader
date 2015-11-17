//
//  RSSChannelElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSChannelElement.h"

@implementation RSSChannelElement

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemsOfChannel = [NSMutableArray array];
        _languageOfChannel = @"";
        _copyrightOfChannel = @"";
    }
    return self;
}

- (void)addItem:(RSSItemElement *)item {
    if (self.feedURL != nil) {
        item.feedURL = self.feedURL;
    }
    [_itemsOfChannel addObject:item];
}

- (void)setFeedURL:(NSURL *)aFeedUrl {
    [super setFeedURL:aFeedUrl];
    // let items' feedURL as same as Channel's.
    for (RSSItemElement *item in self.itemsOfChannel) {
        item.feedURL = aFeedUrl;
    }
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
