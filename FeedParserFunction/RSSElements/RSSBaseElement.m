//
//  RSSBaseElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSBaseElement.h"
#import "RSSSchema.h"
#import "AtomSchema.h"
#import "NSDate+helper.h"

@implementation RSSBaseElement

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleOfElement = @"";
        _linkOfElement = @"";
        _descriptionOfElement = @"";
        _pubDateStringOfElement = @"";
        _imageUrlArray = [NSMutableArray array];
        _feedURL = nil;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [self init];
    if (self) {
        _titleOfElement = title;
        _linkOfElement = @"";
        _feedURL = nil;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        _titleOfElement = @"";
        _linkOfElement = @"";
        _feedURL = url;
    }
    return self;
}

- (NSData *)favIconData {
    if (_favIconData == nil) {
        if (self.favIconURL != nil) {
            // 1. load it from favIconURL
            _favIconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.favIconURL]];
        } else {
            // 2. get favIconURL from url of channel, then load favIcon.
            NSURL *url = [NSURL URLWithString:self.linkOfElement];
            NSString *imageUrlString = [NSString stringWithFormat:@"%@://%@/favicon.ico", url.scheme, url.host];
            NSError *error = nil;
            _favIconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString] options:NSDataReadingMappedIfSafe error:&error];
            if (error != nil) {
                NSLog(@"favIconData dataWithContentsOfURL error : %@", error);
            } else if (_favIconData != nil) {
                _favIconURL = imageUrlString;
            }
        }
    }
    return _favIconData;
}

- (void)setPubDateStringOfElement:(NSString *)pubDateStringOfElement {
    _pubDateStringOfElement = pubDateStringOfElement;
    if (_pubDateStringOfElement != nil) {
        _pubDateOfElement = [RSSSchema convertString2Date:_pubDateStringOfElement];
        if (_pubDateOfElement == nil) {
            _pubDateOfElement = [AtomSchema convertString2Date:_pubDateStringOfElement];
        }
    }
}

- (void)setPubDateOfElement:(NSDate *)pubDateOfElement {
    _pubDateOfElement = pubDateOfElement;
    _pubDateStringOfElement = [_pubDateOfElement convertToString];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    [description appendFormat:@"  feedURL=%@", self.feedURL.absoluteString];
    [description appendFormat:@"  titleOfElement=%@", self.titleOfElement];
    [description appendFormat:@"  category=%@", self.categoryOfElement];
    [description appendFormat:@"  starred=%d", self.starred];
    [description appendFormat:@", linkOfElement=%@", self.linkOfElement];
    [description appendFormat:@", pubDateOfElement=%@", self.pubDateOfElement];
    [description appendFormat:@", descriptionOfElement=%@", self.descriptionOfElement];
    [description appendFormat:@", imageCount=%lu", self.imageUrlArray.count];
    [description appendFormat:@", favIconURL=%@", self.favIconURL];
    [description appendString:@">"];
    return description;
}

@end
