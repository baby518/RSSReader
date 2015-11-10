//
//  FeedItemTableDataSource.h
//  RSSReader
//
//  Created by Apple on 15-11-9.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSItemElement.h"
#import "RSSChannelElement.h"

@protocol FeedChannelDelegate <NSObject>
- (RSSChannelElement *)getChannelElement;
@end

@interface FeedItemTableDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>
- (id)initWithChannelDelegate:(id <FeedChannelDelegate>)aDelegate;
@end
