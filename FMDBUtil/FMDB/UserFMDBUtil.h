//
// Created by zhangchao on 15/8/9.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFMDBUtil.h"

/** add update and query functions. */
@interface UserFMDBUtil : BaseFMDBUtil

+ (UserFMDBUtil *)getInstance;

//add
- (BOOL)addChannelElement:(RSSChannelElement *)element;

//delete
- (BOOL)deleteChannelFromURL:(NSString *)url;

//update
- (BOOL)updateChannelCategoryFromURL:(NSString *)url to:(NSString *)category;
- (BOOL)updateChannelStarredFromURL:(NSString *)url to:(BOOL)starred;
- (BOOL)updateChannelElement:(RSSChannelElement *)element;
@end