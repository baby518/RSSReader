//
//  RSSItemElement.h
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSBaseElement.h"

@interface RSSItemElement : RSSBaseElement

@property(nonatomic, strong) NSString *authorOfItem;
@property(nonatomic, strong) NSString *authorLinkOfItem;
@property(nonatomic, strong) NSString *guidOfItem;
@property(nonatomic, strong) NSString *contentOfItem;
@property(nonatomic, assign) BOOL read;
@end
