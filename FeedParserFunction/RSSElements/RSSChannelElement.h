//
//  RSSChannelElement.h
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSItemElement.h"

@interface RSSChannelElement : RSSBaseElement

@property(nonatomic, strong) NSString *languageOfChannel;
@property(nonatomic, strong) NSString *copyrightOfChannel;

// array of items in this channel
@property (nonatomic, strong, readonly) NSMutableArray* itemsOfChannel;

- (void)addItem:(RSSItemElement *)item;
@end
