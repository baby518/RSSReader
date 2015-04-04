//
//  RSSParser.h
//  RSSReader
//
//  Created by zhangchao on 15/4/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogHelper.h"

@interface RSSParser : NSObject
@property (nonatomic, strong, readonly) NSData* xmlData;
- (id)initWithData:(NSData *)data;
@end
