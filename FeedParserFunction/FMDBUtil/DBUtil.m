//
// Created by Apple on 15-11-26.
// Copyright (c) 2015 zhangchao. All rights reserved.
//

#import "DBUtil.h"
#import "UserFMDBUtil.h"

@interface DBUtil ()
@property(nonatomic, strong) UserFMDBUtil *userDB;
@end

@implementation DBUtil {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDB = [UserFMDBUtil getInstance];
        [_userDB closeDB];
    }
    return self;
}

- (void)deleteChannelOfUserDB:(RSSChannelElement *)element {
    _userDB = [UserFMDBUtil getInstance];
    if (self.userDB != nil) {
        [self.userDB deleteChannelFromURL:element.feedURL.absoluteString];
    }
    [_userDB closeDB];
}

- (NSArray *)getAllChannelsOfUserDB {
    NSArray *result;
    _userDB = [UserFMDBUtil getInstance];
    if (self.userDB != nil) {
        result = [self.userDB getAllFeedChannels];
    }
    [_userDB closeDB];
    return result;
}

- (RSSChannelElement *)getChannelFromUserDB:(NSString *)urlString {
    RSSChannelElement *result;
    _userDB = [UserFMDBUtil getInstance];
    if (self.userDB != nil) {
        result = [self.userDB getChannelFromURL:urlString];
    }
    [_userDB closeDB];
    return result;
}
@end