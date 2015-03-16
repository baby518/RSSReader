//
//  RSSChannelElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSChannelElement.h"

@implementation RSSChannelElement

- (void)addItem:(RSSItemElement *)item {
    [_itemsOfChannel addObject:item];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    [description appendFormat:@"  titleOfElement=%@", self.titleOfElement];
    [description appendFormat:@", linkOfElement=%@", self.linkOfElement];
    [description appendFormat:@", pubDateOfElement=%@", self.pubDateOfElement];
    [description appendFormat:@", descriptionOfElement=%@", self.descriptionOfElement];
    [description appendFormat:@", languageOfChannel=%@", self.languageOfChannel];
    [description appendFormat:@", copyrightOfChannel=%@", self.copyrightOfChannel];
    [description appendString:@">"];
    return description;
}
@end
