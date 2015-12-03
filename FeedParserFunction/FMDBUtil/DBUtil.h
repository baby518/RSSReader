//
// Created by Apple on 15-11-26.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannelElement;

@interface DBUtil : NSObject
- (instancetype)init;

- (void)addChannelToUserDB:(RSSChannelElement *)element;
- (void)deleteChannelOfUserDB:(RSSChannelElement *)element;
- (NSArray *)getAllChannelsOfUserDB;
- (RSSChannelElement *)getChannelFromUserDB:(NSString *)urlString;
@end