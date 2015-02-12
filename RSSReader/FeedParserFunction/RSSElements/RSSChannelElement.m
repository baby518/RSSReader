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
@end
